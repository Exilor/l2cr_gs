class NpcAI::Sandstorms < AbstractNpcAI
  # NPCs
  private SANDSTORM = 32350
  # Skills
  private GUST = SkillHolder.new(5435) # Gust

  def initialize
    super(self.class.simple_name, "ai/group_template")
    add_aggro_range_enter_id(SANDSTORM) # Sandstorm
  end

  def on_aggro_range_enter(npc, player, is_summon)
    npc.target = player
    npc.do_cast(GUST)

    super
  end
end
