class EffectHandler::Sow < AbstractEffect
  def instant? : Bool
    true
  end

  def on_start(info)
    return unless pc = info.effector.as?(L2PcInstance)
    return unless mob = info.effected.as?(L2MonsterInstance)

    if mob.dead? || !mob.template.can_be_sown? || mob.seeded? || mob.seeder_id != pc.l2id
      return
    end

    return unless seed = mob.seed

    unless pc.destroy_item_by_item_id("Consume", seed.seed_id, 1, mob, false)
      return
    end

    if calc_success(pc, mob, seed)
      pc.send_packet(Sound::ITEMSOUND_QUEST_ITEMGET.packet)
      mob.set_seeded(pc)
      sm = SystemMessage.the_seed_was_successfully_sown
    else
      sm = SystemMessage.the_seed_was_not_sown
    end

    if party = pc.party
      party.broadcast_packet(sm)
    else
      pc.send_packet(sm)
    end

    mob.intention = AI::IDLE
  end

  private def calc_success(pc, mob, seed)
    min_level_seed = seed.level - 5
    max_level_seed = seed.level + 5
    pc_level = pc.level
    mob_level = mob.level
    basic_success = seed.alternative? ? 20 : 90

    if mob_level < min_level_seed
      basic_success -= 5 * (min_level_seed - mob_level)
    end

    if mob_level > max_level_seed
      basic_success -= 5 * (mob_level - max_level_seed)
    end

    diff = (pc_level - mob_level).abs

    if diff > 5
      basic_success -= 5 * (diff - 5)
    end

    Rnd.rand(99) < Math.max(basic_success, 1)
  end
end
