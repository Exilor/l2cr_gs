class Packets::Incoming::RequestExEnchantSkillRouteChange < GameClientPacket
  @skill_id = 0
  @skill_lvl = 0

  private def read_impl
    @skill_id = d
    @skill_lvl = d
  end

  private def run_impl
    return if @skill_id <= 0 || @skill_lvl <= 0
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

    return unless skill = SkillData[@skill_id, @skill_lvl]?

    req_item_id = EnchantSkillGroupsData::CHANGE_ENCHANT_BOOK

    esl = EnchantSkillGroupsData.get_skill_enchantment_by_skill_id(@skill_id)
    return unless esl

    old_level = pc.get_skill_level(@skill_id)
    if old_level <= 100
      return
    end
    current_enchant_level = old_level % 100
    if current_enchant_level != @skill_lvl % 100
      return
    end

    unless esd = esl.get_enchant_skill_holder(@skill_lvl)
      return
    end

    required_sp = esd.sp_cost
    required_adena = esd.adena_cost.to_i64

    if pc.sp >= required_sp
      spb = pc.inventory.get_item_by_item_id(req_item_id)
      if Config.es_sp_book_needed
        unless spb
          pc.send_packet(SystemMessageId::YOU_DONT_HAVE_ALL_ITENS_NEEDED_TO_CHANGE_SKILL_ENCHANT_ROUTE)
          return
        end
      end

      if pc.inventory.adena < required_adena
        pc.send_packet(SystemMessageId::YOU_DONT_HAVE_ALL_OF_THE_ITEMS_NEEDED_TO_ENCHANT_THAT_SKILL)
        return
      end

      check = pc.remove_sp(required_sp)
      if Config.es_sp_book_needed
        check &= pc.destroy_item("Consume", spb.not_nil!.l2id, 1, pc, true)
      end

      check &= pc.destroy_item_by_item_id("Consume", Inventory::ADENA_ID, required_adena, pc, true)

      unless check
        pc.send_packet(SystemMessageId::YOU_DONT_HAVE_ALL_OF_THE_ITEMS_NEEDED_TO_ENCHANT_THAT_SKILL)
        return
      end

      level_penalty = Rnd.rand(Math.min(4, current_enchant_level))
      @skill_lvl -= level_penalty

      if @skill_lvl % 100 == 0
        @skill_lvl = esl.base_level
      end

      if skill = SkillData[@skill_id, @skill_lvl]?
        pc.add_skill(skill, true)
        pc.send_packet(ExEnchantSkillResult::TRUE)
      end

      pc.send_packet(UserInfo.new(pc))
      pc.send_packet(ExBrExtraUserInfo.new(pc))

      if level_penalty == 0
        sm = SystemMessage.skill_enchant_change_successful_s1_level_will_remain
        sm.add_skill_name(@skill_id)
        pc.send_packet(sm)
      else
        sm = SystemMessage.skill_enchant_change_successful_s1_level_was_decreased_by_s2
        sm.add_skill_name(@skill_id)
        sm.add_int(level_penalty)
        pc.send_packet(sm)
      end

      pc.send_skill_list
      new_level = pc.get_skill_level(@skill_id)
      pc.send_packet(ExEnchantSkillInfo.new(@skill_id, new_level))
      pc.send_packet(ExEnchantSkillInfoDetail.new(3, @skill_id, new_level, pc))
      pc.update_shortcuts(@skill_id, new_level)
    else
      pc.send_packet(SystemMessageId::YOU_DONT_HAVE_ENOUGH_SP_TO_ENCHANT_THAT_SKILL)
    end
  end
end
