class Packets::Incoming::RequestExEnchantSkillSafe < GameClientPacket
  @skill_id = 0
  @skill_lvl = 0

  private def read_impl
    @skill_id = d
    @skill_lvl = d
  end

  private def run_impl
    if @skill_id <= 0 || @skill_lvl <= 0
      return
    end

    return unless pc = active_char

    if pc.class_id.level < 3
      pc.send_packet(SystemMessageId::YOU_CANNOT_USE_SKILL_ENCHANT_IN_THIS_CLASS)
      return
    end

    if pc.level < 76
      pc.send_packet(SystemMessageId::YOU_CANNOT_USE_SKILL_ENCHANT_ON_THIS_LEVEL)
      return
    end

    unless pc.allowed_to_enchant_skills?
      pc.send_packet(SystemMessageId::YOU_CANNOT_USE_SKILL_ENCHANT_ATTACKING_TRANSFORMED_BOAT)
      return
    end

    unless skill = SkillData[@skill_id, @skill_lvl]?
      return
    end

    cost_multiplier = Config.safe_enchant_cost_multiplier
    req_item_id = EnchantSkillGroupsData::SAFE_ENCHANT_BOOK

    unless esl = EnchantSkillGroupsData.get_skill_enchantment_by_skill_id(@skill_id)
      return
    end

    unless esd = esl.get_enchant_skill_holder(@skill_lvl)
      warn { "Enchant skill holder for skill with id #{@skill_id} and level #{@skill_lvl} not found." }
      return
    end
    before_enchant_skill_level = pc.get_skill_level(@skill_id)
    if before_enchant_skill_level != esl.get_min_skill_level(@skill_lvl)
      return
    end

    required_sp = esd.sp_cost * cost_multiplier
    required_adena = esd.adena_cost.to_i64 * cost_multiplier
    rate = esd.get_rate(pc)

    if pc.sp >= required_sp
      if Config.safe_es_sp_book_needed
        unless spb = pc.inventory.get_item_by_item_id(req_item_id)
          pc.send_packet(SystemMessageId::YOU_DONT_HAVE_ALL_OF_THE_ITEMS_NEEDED_TO_ENCHANT_THAT_SKILL)
          return
        end
      end

      if pc.inventory.adena < required_adena
        pc.send_packet(SystemMessageId::YOU_DONT_HAVE_ALL_OF_THE_ITEMS_NEEDED_TO_ENCHANT_THAT_SKILL)
        return
      end

      check = pc.remove_sp(required_sp)
      if spb
        check &= pc.destroy_item("Consume", spb.l2id, 1, pc, true)
      end
      check &= pc.destroy_item_by_item_id("Consume", Inventory::ADENA_ID, required_adena, pc, true)

      unless check
        pc.send_packet(SystemMessageId::YOU_DONT_HAVE_ALL_OF_THE_ITEMS_NEEDED_TO_ENCHANT_THAT_SKILL)
        return
      end

      if Rnd.rand(100) <= rate
        # logging
        pc.add_skill(skill, true)
        pc.send_packet(ExEnchantSkillResult::TRUE)
        sm = SystemMessage.you_have_succeeded_in_enchanting_the_skill_s1
        sm.add_skill_name(@skill_id)
        pc.send_packet(sm)
      else
        # logging
        sm = SystemMessage.skill_enchant_failed_s1_level_will_remain
        sm.add_skill_name(@skill_id)
        pc.send_packet(sm)
        pc.send_packet(ExEnchantSkillResult::FALSE)
      end

      pc.send_packet(UserInfo.new(pc))
      pc.send_packet(ExBrExtraUserInfo.new(pc))
      pc.send_skill_list
      new_level = pc.get_skill_level(@skill_id)
      pc.send_packet(ExEnchantSkillInfo.new(@skill_id, new_level))
      pc.send_packet(ExEnchantSkillInfoDetail.new(1, @skill_id, new_level + 1, pc))
      pc.update_shortcuts(@skill_id, new_level)
    else
      pc.send_packet(SystemMessageId::YOU_DONT_HAVE_ENOUGH_SP_TO_ENCHANT_THAT_SKILL)
    end
  end
end
