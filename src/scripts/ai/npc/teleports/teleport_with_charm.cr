class Scripts::TeleportWithCharm < AbstractNpcAI
  # NPCs
  private WHIRPY = 30540
  private TAMIL = 30576
  # Items
  private ORC_GATEKEEPER_CHARM = 1658
  private DWARF_GATEKEEPER_TOKEN = 1659
  # Locations
  private ORC_TELEPORT = Location.new(-80826, 149775, -3043)
  private DWARF_TELEPORT = Location.new(-80826, 149775, -3043)

  def initialize
    super(self.class.simple_name, "ai/npc/Teleports")

    add_start_npc(WHIRPY, TAMIL)
    add_talk_id(WHIRPY, TAMIL)
  end

  def on_talk(npc, pc)
    case npc.id
    when WHIRPY
      if has_quest_items?(pc, DWARF_GATEKEEPER_TOKEN)
        take_items(pc, DWARF_GATEKEEPER_TOKEN, 1)
        pc.tele_to_location(DWARF_TELEPORT)
      else
        return "30540-01.htm"
      end
    when TAMIL
      if has_quest_items?(pc, ORC_GATEKEEPER_CHARM)
        take_items(pc, ORC_GATEKEEPER_CHARM, 1)
        pc.tele_to_location(ORC_TELEPORT)
      else
        return "30576-01.htm"
      end
    end

    super
  end
end
