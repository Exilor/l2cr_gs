class Scripts::RagnaOrcSeer < AbstractNpcAI
  private RAGNA_ORC_SEER = 22697

  def initialize
    super(self.class.simple_name, "ai/individual")
    add_spawn_id(RAGNA_ORC_SEER)
  end

  def on_spawn(npc)
    spawn_minions(npc, Rnd.bool ? "Privates1" : "Privates2")
    super
  end
end
