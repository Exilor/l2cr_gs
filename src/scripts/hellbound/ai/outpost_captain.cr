class Scripts::OutpostCaptain < AbstractNpcAI
  # NPCs
  private CAPTAIN = 18466
  private DEFENDERS = {
    22357, # Enceinte Defender
    22358  # Enceinte Defender
  }
  private DOORKEEPER = 32351

  def initialize
    super(self.class.simple_name, "hellbound/AI")

    add_kill_id(CAPTAIN)
    add_spawn_id(CAPTAIN, DOORKEEPER)
    add_spawn_id(DEFENDERS)
  end

  def on_adv_event(event, npc, player)
    if npc && event.casecmp?("LEVEL_UP")
      npc.delete_me
      HellboundEngine.instance.level = 9
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    if HellboundEngine.instance.level == 8
      add_spawn(DOORKEEPER, npc.spawn.location, false, 0, false)
    end

    super
  end

  def on_spawn(npc)
    npc.no_random_walk = true

    if npc.id == CAPTAIN
      if door = DoorData.get_door(20250001)
        door.close_me
      end
    elsif npc.id == DOORKEEPER
      start_quest_timer("LEVEL_UP", 3000, npc, nil)
    end

    super
  end
end
