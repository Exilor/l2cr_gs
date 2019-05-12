class Scripts::Asher < AbstractNpcAI
  # NPC
  private ASHER = 32714
  # Location
  private LOCATION = Location.new(43835, -47749, -792)
  # Misc
  private ADENA = 50000

  def initialize
    super(self.class.simple_name, "ai/npc/teleports")

    add_first_talk_id(ASHER)
    add_start_npc(ASHER)
  end

  def on_adv_event(event, npc, pc)
    return unless pc

    case event
    when "teleport"
      if pc.adena >= ADENA
        pc.tele_to_location(LOCATION)
        take_items(pc, Inventory::ADENA_ID, ADENA)
      else
        return "32714-02.html"
      end
    when "32714-01.html"
      return event
    end

    super
  end
end
