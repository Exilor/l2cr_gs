class Scripts::Gordon < AbstractNpcAI
  private GORDON = 29095

  def initialize
    super(self.class.simple_name, "ai/individual")

    add_spawn_id(GORDON)
    add_see_creature_id(GORDON)
  end

  def on_see_creature(npc, creature, is_summon)
    if creature.is_a?(L2PcInstance) && creature.cursed_weapon_equipped?
      add_attack_desire(npc, creature)
    end

    super
  end

  def on_spawn(npc)
    npc.as(L2Attackable).can_return_to_spawn_point = false
    super
  end
end
