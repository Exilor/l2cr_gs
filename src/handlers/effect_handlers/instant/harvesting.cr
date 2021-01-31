class EffectHandler::Harvesting < AbstractEffect
  def instant? : Bool
    true
  end

  def on_start(info : BuffInfo)
    return unless pc = info.effector.as?(L2PcInstance)
    return unless mob = info.effected.as?(L2MonsterInstance)
    return unless mob.dead?

    if pc.l2id != mob.seeder_id
      pc.send_packet(SystemMessageId::YOU_ARE_NOT_AUTHORIZED_TO_HARVEST)
    elsif mob.seeded?
      unless calc_success(pc, mob)
        pc.send_packet(SystemMessageId::THE_HARVEST_HAS_FAILED)
        return
      end

      unless item = mob.take_harvest
        return
      end

      pc.inventory.add_item("Harvesting", item.id, item.count, pc, mob)

      if item.count == 1
        sm = SystemMessage.you_picked_up_s1
        sm.add_item_name(item.id)
      else
        sm = SystemMessage.you_picked_up_s1_s2
        sm.add_item_name(item.id)
        sm.add_long(item.count)
      end

      pc.send_packet(sm)

      if party = pc.party
        if item.count == 1
          sm = SystemMessage.c1_harvested_s2s
          sm.add_string(pc.name)
          sm.add_item_name(item.id)
        else
          sm = SystemMessage.c1_harvested_s3_s2s
          sm.add_string(pc.name)
          sm.add_long(item.count)
          sm.add_item_name(item.id)
        end

        party.broadcast_to_party_members(pc, sm)
      end
    else
      pc.send_packet(SystemMessageId::THE_HARVEST_FAILED_BECAUSE_THE_SEED_WAS_NOT_SOWN)
    end
  end

  private def calc_success(pc, mob)
    pc_level = pc.level
    mob_level = mob.level

    diff = (pc_level &- mob_level).abs

    basic_success = 100

    if diff < 5
      basic_success -= (diff - 5) * 5
    end

    if basic_success < 1
      basic_success = 1
    end

    Rnd.rand(99) < basic_success
  end
end
