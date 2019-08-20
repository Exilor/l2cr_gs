class Scripts::Sirra < AbstractNpcAI
  # NPC
  private SIRRA = 32762
  # Misc
  private FREYA_INSTID = 139
  private FREYA_HARD_INSTID = 144

  def initialize
    super(self.class.simple_name, "ai/npc")
    add_first_talk_id(SIRRA)
  end

  def on_first_talk(npc, player)
    world = InstanceManager.get_world(npc.instance_id)

    if world && world.template_id == FREYA_INSTID
      return world.status?(0) ? "32762-easy.html" : "32762-easyfight.html"
    elsif world && world.template_id == FREYA_HARD_INSTID
      return world.status?(0) ? "32762-hard.html" : "32762-hardfight.html"
    end

    "32762.html"
  end
end
