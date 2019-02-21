class NpcAI::Survivor < AbstractNpcAI
  private SURVIVOR = 32632
  private MIN_LEVEL = 75
  private TELEPORT = Location.new(-149406, 255247, -80)

  def initialize
    super(self.class.simple_name, "ai/npc/Teleports")

    add_start_npc(SURVIVOR)
    add_talk_id(SURVIVOR)
  end

  def on_adv_event(event, npc, pc)
    return unless pc

    if event == "32632-2.htm"
      if pc.level < MIN_LEVEL
        event = "32632-3.htm"
      elsif pc.adena < 150_000
        take_items(pc, Inventory::ADENA_ID, 150_000)
        pc.tele_to_location(TELEPORT)
        return
      end
    end

    event
  end

  def on_talk(npc, pc)
    "32632-1.htm"
  end
end
