class Scripts::ToIVortex < AbstractNpcAI
  # NPCs
  private KEPLON = 30949
  private EUCLIE = 30950
  private PITHGON = 30951
  private DIMENSION_VORTEX_1 = 30952
  private DIMENSION_VORTEX_2 = 30953
  private DIMENSION_VORTEX_3 = 30954
  # Items
  private GREEN_DIMENSION_STONE = 4401
  private BLUE_DIMENSION_STONE = 4402
  private RED_DIMENSION_STONE = 4403
  private TOI_FLOOR_ITEMS = {
    "1" => GREEN_DIMENSION_STONE,
    "2" => GREEN_DIMENSION_STONE,
    "3" => GREEN_DIMENSION_STONE,
    "4" => BLUE_DIMENSION_STONE,
    "5" => BLUE_DIMENSION_STONE,
    "6" => BLUE_DIMENSION_STONE,
    "7" => RED_DIMENSION_STONE,
    "8" => RED_DIMENSION_STONE,
    "9" => RED_DIMENSION_STONE,
    "10" => RED_DIMENSION_STONE
  }
  # Locations
  private TOI_FLOORS = {
    "1" => Location.new(114356, 13423, -5096),
    "2" => Location.new(114666, 13380, -3608),
    "3" => Location.new(111982, 16028, -2120),
    "4" => Location.new(114636, 13413, -640),
    "5" => Location.new(114152, 19902, 928),
    "6" => Location.new(117131, 16044, 1944),
    "7" => Location.new(113026, 17687, 2952),
    "8" => Location.new(115571, 13723, 3960),
    "9" => Location.new(114649, 14144, 4976),
    "10" => Location.new(118507, 16605, 5984)
  }
  # Misc
  private DIMENSION_TRADE = {
    "GREEN" => GREEN_DIMENSION_STONE,
    "BLUE" => BLUE_DIMENSION_STONE,
    "RED" => RED_DIMENSION_STONE
  }

  def initialize
    super(self.class.simple_name, "ai/npc/Teleports")

    add_start_npc(
      KEPLON, EUCLIE, PITHGON, DIMENSION_VORTEX_1, DIMENSION_VORTEX_2,
      DIMENSION_VORTEX_3
    )
    add_talk_id(
      KEPLON, EUCLIE, PITHGON, DIMENSION_VORTEX_1, DIMENSION_VORTEX_2,
      DIMENSION_VORTEX_3
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc && npc
    npc_id = npc.id

    case event
    when "1".."10" # "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"
      loc = TOI_FLOORS[event]
      item_id = TOI_FLOOR_ITEMS[event]
      if has_quest_items?(pc, item_id)
        take_items(pc, item_id, 1)
        pc.tele_to_location(loc, true)
      else
        return "no-stones.htm"
      end
    when "GREEN", "BLUE", "RED"
      if pc.adena >= 10000
        take_items(pc, Inventory::ADENA_ID, 10000)
        give_items(pc, DIMENSION_TRADE[event], 1)
      else
        return "#{npc_id}no-adena.htm"
      end
    else
      # [automatically added else]
    end


    super
  end
end
