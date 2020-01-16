class Scripts::Quarry < AbstractNpcAI
  # NPCs
  private SLAVE = 32299
  # Items
  private DROP_LIST = {
    ItemChanceHolder.new(9628, 261),  # Leonard
    ItemChanceHolder.new(9630, 175),  # Orichalcum
    ItemChanceHolder.new(9629, 145),  # Adamantine
    ItemChanceHolder.new(1876, 6667), # Mithril ore
    ItemChanceHolder.new(1877, 1333), # Adamantine nugget
    ItemChanceHolder.new(1874, 2222), # Oriharukon ore
  }
  # Zone
  private ZONE = 40107
  # Misc
  private TRUST = 50

  def initialize
    super(self.class.simple_name, "hellbound/AI/NPC")

    add_spawn_id(SLAVE)
    add_first_talk_id(SLAVE)
    add_start_npc(SLAVE)
    add_talk_id(SLAVE)
    add_kill_id(SLAVE)
    add_enter_zone_id(ZONE)
  end

  def on_adv_event(event, npc, pc)
    case event
    when "FollowMe"
      pc = pc.not_nil!
      npc = npc.not_nil!
      npc.set_intention(AI::FOLLOW, pc)
      npc.target = pc
      npc.auto_attackable = true
      npc.r_hand_id = 9136
      npc.set_walking

      unless get_quest_timer("TIME_LIMIT", npc, nil)
        start_quest_timer("TIME_LIMIT", 900000, npc, nil) # 15 min limit for save
      end
      html = "32299-02.htm"
    when "TIME_LIMIT"
      npc = npc.not_nil!
      ZoneManager.get_zones(npc) do |zone|
        if zone.id == 40108
          npc.target = nil
          npc.set_intention(AI::ACTIVE)
          npc.auto_attackable = false
          npc.r_hand_id = 0
          npc.tele_to_location(npc.spawn.location)
          return
        end
      end
      broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::HUN_HUNGRY)
      npc.do_die(npc)
    when "DECAY"
      if npc && npc.alive?
        if pc = npc.target.as?(L2PcInstance)
          DROP_LIST.each do |item|
            if Rnd.rand(10000) < item.chance
              npc.drop_item(pc, item.id, (item.count * Config.rate_quest_drop).to_i64)
              break
            end
          end
        end
        npc.auto_attackable = false
        npc.delete_me
        npc.spawn.decrease_count(npc)
        HellboundEngine.update_trust(TRUST, true)
      end
    end

    html
  end

  def on_spawn(npc)
    npc.auto_attackable = false
    if npc.is_a?(L2QuestGuardInstance)
      npc.passive = true
    end

    super
  end

  def on_first_talk(npc, pc)
    if HellboundEngine.level != 5
      return "32299.htm"
    end

    "32299-01.htm"
  end

  def on_kill(npc, killer, is_summon)
    npc.auto_attackable = false
    super
  end

  def on_enter_zone(npc, zone)
    if npc.is_a?(L2Attackable)
      if npc.id == SLAVE
        if npc.alive? && !npc.decayed? && npc.intention.follow?
          if HellboundEngine.level == 5
            start_quest_timer("DECAY", 1000, npc, nil)
            begin
              broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::THANK_YOU_FOR_THE_RESCUE_ITS_A_SMALL_GIFT)
            rescue e
              error e
            end
          end
        end
      end
    end

    super
  end
end
