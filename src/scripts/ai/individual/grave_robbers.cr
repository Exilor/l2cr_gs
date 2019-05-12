class Scripts::GraveRobbers < AbstractNpcAI
  private GRAVE_ROBBER_SUMMONER = 22678
  private GRAVE_ROBBER_MEGICIAN = 22679

  def initialize
    super(self.class.simple_name, "ai/individual")
    add_spawn_id(GRAVE_ROBBER_SUMMONER, GRAVE_ROBBER_MEGICIAN)
  end

  def on_spawn(npc)
    spawn_minions(npc, "Privates#{Rnd.rand(1..2)}")
    super
  end
end
