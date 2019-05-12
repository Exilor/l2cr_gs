class Scripts::SeeThroughSilentMove < AbstractNpcAI
  private MONSTERS = {
    18001, 18002, 22199, 22215, 22216, 22217, 22327, 22746, 22747, 22748,
    22749, 22750, 22751, 22752, 22753, 22754, 22755, 22756, 22757, 22758,
    22759, 22760, 22761, 22762, 22763, 22764, 22765, 22794, 22795, 22796,
    22797, 22798, 22799, 22800, 22843, 22857, 25725, 25726, 25727, 29009,
    29010, 29011, 29012, 29013
  }

  def initialize
    super(self.class.simple_name, "ai/group_template")
    add_spawn_id(MONSTERS)
  end

  def on_spawn(npc)
    if npc.is_a?(L2Attackable)
      npc.can_see_through_silent_move = true
    end

    super
  end
end
