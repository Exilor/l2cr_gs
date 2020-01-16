class Scripts::Klemis < AbstractNpcAI
  # NPC
  private KLEMIS = 32734 # Klemis
  # Location
  private LOCATION = Location.new(-180218, 185923, -10576)
  # Misc
  private MIN_LVL = 80

  def initialize
    super(self.class.simple_name, "ai/npc/Teleports")

    add_start_npc(KLEMIS)
    add_talk_id(KLEMIS)
    add_first_talk_id(KLEMIS)
  end

  def on_adv_event(event, npc, pc)
    if pc && event == "portInside"
      if pc.level >= MIN_LVL
        pc.tele_to_location(LOCATION)
      else
        return "32734-01.html"
      end
    end

    super
  end
end
