class Scripts::PavelArchaic < AbstractNpcAI
  private SAFETY_DEVICE    = 18917 # Pavel Safety Device
  private PINCER_GOLEM     = 22801 # Cruel Pincer Golem
  private PINCER_GOLEM2    = 22802 # Cruel Pincer Golem
  private PINCER_GOLEM3    = 22803 # Cruel Pincer Golem
  private JACKHAMMER_GOLEM = 22804 # Horrifying Jackhammer Golem

  def initialize
    super(self.class.simple_name, "ai/group_template")
    add_kill_id(SAFETY_DEVICE, PINCER_GOLEM, JACKHAMMER_GOLEM)
  end

  def on_kill(npc, killer, is_summon)
    if Rnd.rand(100) < 70
      golem1 = add_spawn(PINCER_GOLEM2, npc.x, npc.y, npc.z + 10, npc.heading, false, 0, false)
      add_attack_desire(golem1, killer)

      golem2 = add_spawn(PINCER_GOLEM3, npc.x, npc.y, npc.z + 10, npc.heading, false, 0, false)
      add_attack_desire(golem2, killer)
    end

    super
  end
end
