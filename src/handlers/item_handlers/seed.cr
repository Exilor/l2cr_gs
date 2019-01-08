module ItemHandler::Seed
  extend self
  extend ItemHandler

  def use_item(playable, item, force)
    if !Config.allow_manor
      return false
    elsif !playable.player?
      playable.send_packet(SystemMessageId::ITEM_NOT_FOR_PETS)
      return false
    end

    unless tgt = playable.target
      return false
    end

    if !tgt.npc?
      playable.send_packet(SystemMessageId::INCORRECT_TARGET)
      return false
    elsif !tgt.is_a?(L2MonsterInstance) || tgt.raid? || tgt.is_a?(L2ChestInstance)
      playable.send_packet(SystemMessageId::THE_TARGET_IS_UNAVAILABLE_FOR_SEEDING)
      return false
    end

    target = tgt.as(L2MonsterInstance)

    if target.dead?
      playable.send_packet(SystemMessageId::INCORRECT_TARGET)
      return false
    elsif target.seeded?
      playable.action_failed
      return false
    end

    seed = CastleManorManager.get_seed(item.id)

    if seed.nil?
      return false
    elsif seed.castle_id != MapRegionManager.get_area_castle(playable) # (L2J) TODO: replace me with tax zone
      playable.send_packet(SystemMessageId::THIS_SEED_MAY_NOT_BE_SOWN_HERE)
      return false
    end

    pc = playable.acting_player
    target.set_seeded(seed, pc)

    if skills = item.template.skills
      skills.each do |sk|
        pc.use_magic(sk.skill, false, false)
      end
    end

    true
  end
end
