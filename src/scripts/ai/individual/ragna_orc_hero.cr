class Scripts::RagnaOrcHero < AbstractNpcAI
  private RAGNA_ORC_HERO = 22693

  def initialize
    super(self.class.simple_name, "ai/individual")
    add_spawn_id(RAGNA_ORC_HERO)
  end

  def on_spawn(npc)
    spawn_minions(npc, Rnd.rand(100) < 70 ? "Privates1" : "Privates2")
    super
  end
end
