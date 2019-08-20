module ItemHandler::FishShots
  extend self
  extend ItemHandler

  def use_item(playable, item, force)
    unless playable.player?
      playable.send_packet(SystemMessageId::ITEM_NOT_FOR_PETS)
      return false
    end

    pc = playable.acting_player
    return false unless weapon_inst = pc.active_weapon_instance?
    return false unless weapon_item = pc.active_weapon_item?

    unless weapon_item.item_type.fishingrod?
      return false
    end

    if pc.charged_shot?(ShotType::FISH_SOULSHOTS)
      return false
    end

    count = item.count
    return false if count < 1
    skills = item.template.skills

    if skills.nil?
      warn { "#{item.name} is missing skills." }
      return false
    end

    grade_check = item.etc_item?
    grade_check &= item.etc_item!.default_action == ActionType::FISHINGSHOT
    grade_check &= weapon_inst.template.item_grade_s_plus == item.template.item_grade_s_plus

    unless grade_check
      debug "Grade check failed."
      return false
    end

    pc.set_charged_shot(ShotType::FISH_SOULSHOTS, true)
    pc.destroy_item_without_trace("Consume", item.l2id, 1, nil, false)

    old_target = pc.target
    pc.target = pc
    msu = MagicSkillUse.new(pc, skills[0].skill_id, skills[0].skill_lvl, 0, 0)
    Broadcast.to_self_and_known_players(pc, msu)
    pc.target = old_target

    true
  end
end
