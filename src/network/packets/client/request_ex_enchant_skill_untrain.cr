class Packets::Incoming::RequestExEnchantSkillUntrain < GameClientPacket
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

    s = EnchantSkillGroupsData.get_skill_enchantment_by_skill_id(@skill_id)
    unless s
      debug { "No skill enchantment found for skill #{@skill_id}." }
      return
    end

    if @skill_lvl % 100 == 0
      @skill_lvl = s.base_level
    end

    unless skill = SkillData[@skill_id, @skill_lvl]?
      debug { "No skill found for skill with id #{@skill_id} and level #{@skill_lvl}." }
      return
    end

    req_item_id = EnchantSkillGroupsData::UNTRAIN_ENCHANT_BOOK

    old_lvl = pc.get_skill_level(@skill_id)

    if old_lvl - 1 != @skill_lvl
      if old_lvl % 100 != 1 || @skill_lvl != s.base_level
        debug "Skill level mismatch for unenchanting #{skill}."
        return
      end
    end

    unless esd = s.get_enchant_skill_holder(old_lvl)
      warn { "Can't find enchant skill holder for #{s} at #{old_lvl}." }
      return
    end

    required_sp = esd.sp_cost
    required_items = esd.adena_cost.to_i64

    spb = pc.inventory.get_item_by_item_id(req_item_id)

    if Config.es_sp_book_needed
      if !spb
        pc.send_packet(SystemMessageId::YOU_DONT_HAVE_ALL_OF_THE_ITEMS_NEEDED_TO_ENCHANT_THAT_SKILL)
        return
      end
    end

    if pc.inventory.adena < required_items
      pc.send_packet(SystemMessageId::YOU_DONT_HAVE_ALL_OF_THE_ITEMS_NEEDED_TO_ENCHANT_THAT_SKILL)
      return
    end

    check = true

    if Config.es_sp_book_needed
      check &= pc.destroy_item("Consume", spb.not_nil!.l2id, 1, pc, true)
    end

    check &= pc.destroy_item_by_item_id("Consume", Inventory::ADENA_ID, required_items, pc, true)

    unless check
      pc.send_packet(SystemMessageId::YOU_DONT_HAVE_ALL_OF_THE_ITEMS_NEEDED_TO_ENCHANT_THAT_SKILL)
      return
    end

    pc.stat.add_sp((required_sp * 0.8).to_i)

    if Config.log_skill_enchants
      Logs[:enchant_skill].info { "UNTRAINED #{skill} using #{spb} by #{pc}." }
    end

    pc.add_skill(skill, true)
    pc.send_packet(ExEnchantSkillResult::TRUE)

    debug { "Untrained #{skill}." }

    pc.send_packet(UserInfo.new(pc))
    pc.send_packet(ExBrExtraUserInfo.new(pc))

    if @skill_lvl > 100
      sm = SystemMessage.untrain_successful_skill_s1_enchant_level_decreased_by_one
    else
      sm = SystemMessage.untrain_successful_skill_s1_enchant_level_reseted
    end

    sm.add_skill_name(@skill_id)
    pc.send_packet(sm)

    pc.send_skill_list
    after_lvl = pc.get_skill_level(@skill_id)
    pc.send_packet(ExEnchantSkillInfo.new(@skill_id, after_lvl))
    pc.send_packet(ExEnchantSkillInfoDetail.new(2, @skill_id, after_lvl &- 1, pc))
    pc.update_shortcuts(@skill_id, after_lvl)
  end
end
