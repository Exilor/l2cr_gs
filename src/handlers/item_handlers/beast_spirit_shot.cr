module ItemHandler::BeastSpiritShot
  extend self
  extend ItemHandler

  def use_item(playable : L2Playable, item : L2ItemInstance, force_use : Bool) : Bool
    unless playable.player?
      playable.send_packet(SystemMessageId::ITEM_NOT_FOR_PETS)
      return false
    end

    owner = playable.acting_player

    unless summon = owner.summon
      owner.send_packet(SystemMessageId::PETS_ARE_NOT_AVAILABLE_AT_THIS_TIME)
      return false
    end

    if summon.dead?
      owner.send_packet(SystemMessageId::SOULSHOTS_AND_SPIRITSHOTS_ARE_NOT_AVAILABLE_FOR_A_DEAD_PET)
      return false
    end

    item_id = item.id
    blessed = item_id.in?(6647, 20334)
    shot_consumption = summon.spiritshots_per_hit
    shot_count = item.count
    skills = item.template.skills

    if skills.nil? || skills.empty?
      warn { "#{item.template} has no skills." }
      return false
    end

    if shot_count < shot_consumption
      owner.send_packet(SystemMessageId::NOT_ENOUGH_SPIRITSHOTS_FOR_PET)
      return false
    end

    if summon.charged_shot?(blessed ? ShotType::BLESSED_SPIRITSHOTS : ShotType::SPIRITSHOTS)
      return false
    end

    unless owner.destroy_item_without_trace("Consume", item.l2id, shot_consumption.to_i64, nil, false)
      unless owner.disable_auto_shot(item_id)
        owner.send_packet(SystemMessageId::NOT_ENOUGH_SPIRITSHOTS_FOR_PET)
      end
      return false
    end

    summon.set_charged_shot(blessed ? ShotType::BLESSED_SPIRITSHOTS : ShotType::SPIRITSHOTS, true)

    sm = SystemMessage.use_s1_
    sm.add_item_name(item_id)
    owner.send_packet(sm)

    owner.send_packet(SystemMessageId::PET_USE_SPIRITSHOT)
    id, level = skills[0].skill_id, skills[0].skill_lvl
    msu = MagicSkillUse.new(summon, summon, id, level, 0, 0)
    Broadcast.to_self_and_known_players_in_radius(owner, msu, 600)
    true
  end
end
