class Scripts::CrumaTower < AbstractNpcAI
  private MOZELLA = 30483

  private TELEPORTS = {
    Location.new(17776, 113968, -11671),
    Location.new(17680, 113968, -11671)
  }

  private MAX_LEVEL = 55

  def initialize
    super(self.class.simple_name, "ai/npc/Teleports")

    add_first_talk_id(MOZELLA)
    add_start_npc(MOZELLA)
    add_talk_id(MOZELLA)
  end

  def on_talk(npc, pc)
    if pc.level <= MAX_LEVEL
      pc.tele_to_location(TELEPORTS.sample(random: Rnd))
      nil
    else
      "30483-1.html"
    end
  end
end
