module ItemHandler::SoulShots
  extend self
  extend ItemHandler

  def use_item(playable, item, force) : Bool
    unless pc = playable.as?(L2PcInstance)
      playable.send_packet(SystemMessageId::ITEM_NOT_FOR_PETS)
      return false
    end

    weapon_inst = pc.active_weapon_instance?
    item_id = item.id
    skills = item.template.skills

    if skills.nil? || skills.empty?
      warn { "#{item.template} has no skills." }
      return false
    end

    if weapon_inst.nil? || pc.active_weapon_item.soulshot_count == 0
      unless pc.active_shots.includes?(item_id)
        pc.send_packet(SystemMessageId::CANNOT_USE_SOULSHOTS)
      end
      return false
    end

    unless item.etc_item? && item.template.default_action.soulshot? && weapon_inst.template.item_grade_s_plus == item.template.item_grade_s_plus
      unless pc.active_shots.includes?(item_id)
        pc.send_packet(SystemMessageId::SOULSHOTS_GRADE_MISMATCH)
      end
      return false
    end

    begin
      pc.soulshot_lock.lock

      if pc.charged_shot?(ShotType::SOULSHOTS)
        return false
      end

      ss_count = pc.active_weapon_item.soulshot_count
      if pc.active_weapon_item.reduced_soulshot > 0 && Rnd.rand(100) < pc.active_weapon_item.reduced_soulshot_chance
        ss_count = pc.active_weapon_item.reduced_soulshot
      end

      unless pc.destroy_item_without_trace("Consume", item.l2id, ss_count.to_i64, nil, false)
        unless pc.disable_auto_shot(item_id)
          pc.send_packet(SystemMessageId::NOT_ENOUGH_SOULSHOTS)
        end

        return false
      end

      pc.set_charged_shot(ShotType::SOULSHOTS, true)
    ensure
      pc.soulshot_lock.unlock
    end
    sm = SystemMessage.use_s1_
    sm.add_item_name(item_id)
    pc.send_packet(sm)

    pc.send_packet(SystemMessageId::ENABLED_SOULSHOT)
    id, level = skills[0].skill_id, skills[0].skill_lvl
    msu = MagicSkillUse.new(pc, pc, id, level, 0, 0)
    Broadcast.to_self_and_known_players_in_radius(pc, msu, 600)
    true
  end
end
