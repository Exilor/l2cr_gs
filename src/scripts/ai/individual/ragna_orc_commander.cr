class Scripts::RagnaOrcCommander < AbstractNpcAI
  private RAGNA_ORC_COMMANDER = 22694

  def initialize
    super(self.class.simple_name, "ai/individual")
    add_spawn_id(RAGNA_ORC_COMMANDER)
  end

  def on_spawn(npc)
    spawn_minions(npc, "Privates1")
    spawn_minions(npc, Rnd.bool ? "Privates2" : "Privates3")

    super
  end
end
