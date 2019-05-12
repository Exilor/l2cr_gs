class Scripts::Typhoon < AbstractNpcAI
  # NPCs
  private TYPHOON = 25539
  # Skills
  private STORM = SkillHolder.new(5434) # Gust

  def initialize
    super(self.class.simple_name, "hellbound/AI")

    add_aggro_range_enter_id(TYPHOON)
    add_spawn_id(TYPHOON)

    # If it's not found now, it will happen later regardless.
    if boss = RaidBossSpawnManager.bosses[TYPHOON]?
      on_spawn(boss)
    end
  end

  def on_adv_event(event, npc, player)
    if npc && npc.alive? && event.casecmp?("CAST")
      npc.do_simultaneous_cast(STORM)
      start_quest_timer("CAST", 5000, npc, nil)
    end

    super
  end

  def on_aggro_range_enter(npc, player, is_summon)
    npc.do_simultaneous_cast(STORM)
    super
  end

  def on_spawn(npc)
    start_quest_timer("CAST", 5000, npc, nil)
    super
  end
end
