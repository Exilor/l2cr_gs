class Scripts::GolemTrader < AbstractNpcAI
  private GOLEM_TRADER = 13128

  def initialize
    super(self.class.simple_name, "ai/npc/Summons")
    add_spawn_id(GOLEM_TRADER)
  end

  def on_spawn(npc)
    npc.schedule_despawn(180_000)
    super
  end
end
