# custom
class Scripts::CorpseOfDeadman < AbstractNpcAI
  private NPCS = {
    18119 # Corpse of Deadman
  }

  def initialize
    super(self.class.simple_name, "ai/group_template")
    add_spawn_id(NPCS)
  end

  def on_spawn(npc)
    npc.current_hp = 0.0
    npc.dead = true
    super
  end
end
