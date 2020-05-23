class Scripts::NonLethalableNpcs < AbstractNpcAI
  private NPCS = {
    22857, # Knoriks (Lair of Antharas)
    35062 # Headquarters
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
