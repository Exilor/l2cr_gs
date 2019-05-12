class Scripts::HellboundCore < AbstractNpcAI
  # NPCs
  private NAIA = 18484
  private HELLBOUND_CORE = 32331
  # Skills
  private BEAM = SkillHolder.new(5493)

  def initialize
    super(self.class.simple_name, "hellbound/AI")
    add_spawn_id(HELLBOUND_CORE, NAIA)
  end

  def on_adv_event(event, npc, player)
    if npc && event.casecmp?("cast") && HellboundEngine.level <= 6
      npc.known_list.each_character(900) do |naia|
        if naia.monster? && naia.id == NAIA && naia.alive? && !naia.channeling?
          naia.target = npc
          naia.do_simultaneous_cast(BEAM)
        end
      end
      start_quest_timer("cast", 10000, npc, nil)
    end

    super
  end

  def on_spawn(npc)
    if npc.id == NAIA
      npc.no_rnd_walk = true
    else
      start_quest_timer("cast", 10000, npc, nil)
    end

    super
  end
end
