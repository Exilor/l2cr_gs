class Scripts::Solomon < AbstractNpcAI
  # NPCs
  private SOLOMON = 32355

  def initialize
    super(self.class.simple_name, "hellbound/AI/NPC")
    add_first_talk_id(SOLOMON)
  end

  def on_first_talk(npc, player)
    if HellboundEngine.instance.level == 5
      return "32355-01.htm"
    elsif HellboundEngine.instance.level > 5
      return "32355-01a.htm"
    end

    super
  end
end
