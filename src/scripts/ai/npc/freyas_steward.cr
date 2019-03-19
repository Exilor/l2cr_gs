class NpcAI::FreyasSteward < AbstractNpcAI
  # NPC
  private FREYAS_STEWARD = 32029
  # Location
  private TELEPORT_LOC = Location.new(103045, -124361, -2768)
  # Misc
  private MIN_LEVEL = 82

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_start_npc(FREYAS_STEWARD)
    add_first_talk_id(FREYAS_STEWARD)
    add_talk_id(FREYAS_STEWARD)
  end

  def on_first_talk(npc, pc)
    "32029.html"
  end

  def on_talk(npc, pc)
    if pc.level >= MIN_LEVEL
      pc.tele_to_location(TELEPORT_LOC)
      return
    end

    "32029-1.html"
  end
end
