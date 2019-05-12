class Scripts::Slaves < AbstractNpcAI
  # NPCs
  private MASTERS = {
    22320, # Junior Watchman
    22321  # Junior Summoner
  }
  # Locations
  private MOVE_TO = Location.new(-25451, 252291, -3252, 3500)
  # Misc
  private TRUST_REWARD = 10

  def initialize
    super(self.class.simple_name, "hellbound/AI")

    add_spawn_id(MASTERS)
    add_kill_id(MASTERS)
  end

  def on_spawn(npc)
    npc = npc.as(L2MonsterInstance)
    npc.enable_minions = HellboundEngine.level < 5
    npc.on_kill_delay = 1000

    super
  end

  def on_kill(npc, killer, is_summon)
    npc = npc.as(L2MonsterInstance)
    npc.minion_list.spawned_minions.each do |slave|
      if slave.dead?
        next
      end
      slave.clear_aggro_list
      slave.abort_attack
      slave.abort_cast
      broadcast_npc_say(slave, Say2::NPC_ALL, NpcString::THANK_YOU_FOR_SAVING_ME_FROM_THE_CLUTCHES_OF_EVIL)

      if HellboundEngine.level >= 1 && HellboundEngine.level <= 2
        HellboundEngine.update_trust(TRUST_REWARD, false)
      end
      slave.set_intention(AI::MOVE_TO, MOVE_TO)
      DecayTaskManager.add(slave)
    end

    super
  end
end
