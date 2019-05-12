class Packets::Incoming::RequestExEnchantSkill < GameClientPacket
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

    esl = EnchantSkillGroupsData.get_skill_enchantment_by_skill_id(@skill_id)
    unless esl
      warn "No L2EnchantSkillLearn found for skill with ID #{@skill_id}."
      return
    end

    unless esd = esl.get_enchant_skill_holder(@skill_lvl)
      error "Missing EnchantSkillHolder for #{skill}."
      return
    end
    old_level = pc.get_skill_level(@skill_id)
    if old_level != esl.get_min_skill_level(@skill_lvl)
      warn "Level mismatch for enchanting #{skill}."
      return
    end

    cost_multiplier = Config.normal_enchant_cost_multiplier
    required_sp = esd.sp_cost * cost_multiplier

    if pc.sp >= required_sp
      use_book = @skill_lvl % 100 == 1
      req_item_id = EnchantSkillGroupsData::NORMAL_ENCHANT_BOOK
      spb = pc.inventory.get_item_by_item_id(req_item_id)

      if Config.es_sp_book_needed && use_book && !spb
        pc.send_packet(SystemMessageId::YOU_DONT_HAVE_ALL_OF_THE_ITEMS_NEEDED_TO_ENCHANT_THAT_SKILL)
        return
      end

      required_adena = esd.adena_cost.to_i64 * cost_multiplier
      if pc.inventory.adena < required_adena
        pc.send_packet(SystemMessageId::YOU_DONT_HAVE_ALL_OF_THE_ITEMS_NEEDED_TO_ENCHANT_THAT_SKILL)
        return
      end

      check = pc.stat.remove_sp(required_sp)
      debug "Has enough sp: #{check}."
      if Config.es_sp_book_needed && use_book
        check &= pc.destroy_item("Consume", spb.not_nil!.l2id, 1, pc, true)
      end
      debug "Has the correct book: #{check}."
      check &= pc.destroy_item_by_item_id("Consume", Inventory::ADENA_ID, required_adena, pc, true)
      debug "Has enough adena (#{required_adena}): #{check}."
      unless check
        pc.send_packet(SystemMessageId::YOU_DONT_HAVE_ALL_OF_THE_ITEMS_NEEDED_TO_ENCHANT_THAT_SKILL)
        return
      end

      rate = esd.get_rate(pc)

      if Rnd.rand(100) <= rate
        pc.add_skill(skill, true)
        pc.send_packet(ExEnchantSkillResult::TRUE)
        sm = SystemMessage.you_have_succeeded_in_enchanting_the_skill_s1
        sm.add_skill_name(@skill_id)
        pc.send_packet(sm)
      else
        pc.add_skill(SkillData[@skill_id, esl.base_level], true)
        sm = SystemMessage.you_have_failed_to_enchant_the_skill_s1
        sm.add_skill_name(@skill_id)
        pc.send_packet(sm)
        pc.send_packet(ExEnchantSkillResult::FALSE)
      end
      pc.send_packet(UserInfo.new(pc))
      pc.send_packet(ExBrExtraUserInfo.new(pc))
      pc.send_skill_list
      new_level = pc.get_skill_level(@skill_id)
      pc.send_packet(ExEnchantSkillInfo.new(@skill_id, new_level))
      pc.send_packet(ExEnchantSkillInfoDetail.new(0, @skill_id, new_level + 1, pc))
      pc.update_shortcuts(@skill_id, new_level)
    else
      debug "Required sp: #{required_sp}, available: #{pc.sp}."
      pc.send_packet(SystemMessageId::YOU_DONT_HAVE_ENOUGH_SP_TO_ENCHANT_THAT_SKILL)
    end
  end
end
