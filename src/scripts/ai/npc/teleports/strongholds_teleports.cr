class Scripts::StrongholdsTeleports < AbstractNpcAI
  private NPCS = {
    32163,
    32181,
    32184,
    32186
  }

  def initialize
    super(self.class.simple_name, "ai/npc/Teleports")
    add_first_talk_id(NPCS)
  end

  def on_first_talk(npc, pc)
    if pc.level < 20
      return "#{npc.id}.htm"
    end

    "#{npc.id}-no.htm"
  end
end
