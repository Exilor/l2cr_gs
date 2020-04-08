class Scripts::EvasGiftBox < AbstractNpcAI
  private BOX = 32342 # Eva's Gift Box
  private BUFF = 1073 # Kiss of Eva
  private CORAL = ItemHolder.new(9692, 1) # Red Coral
  private CRYSTAL = ItemHolder.new(9693, 1) # Crystal Fragment

  def initialize
    super(self.class.simple_name, "ai/individual")

    add_kill_id(BOX)
    add_spawn_id(BOX)
  end

  def on_kill(npc, killer, is_summon)
    if killer.affected_by_skill?(BUFF)
      if Rnd.bool
        npc.drop_item(killer, CRYSTAL)
      end

      if Rnd.rand(100) < 33
        npc.drop_item(killer, CORAL)
      end
    end

    super
  end

  def on_spawn(npc)
    npc.no_random_walk = true
    npc.as(L2Attackable).on_kill_delay = 0

    super
  end
end
