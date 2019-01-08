class NpcAI::NonLethalableNpcs < AbstractNpcAI
  private NPCS = {
    35062, # Headquarters
  }

  def initialize
    super(self.class.simple_name, "ai/group_template")
    add_spawn_id(NPCS)
  end

  def on_spawn(npc)
    npc.lethalable = false
    super
  end
end
