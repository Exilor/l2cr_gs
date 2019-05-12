class Scripts::TeleportToFantasy < AbstractNpcAI
  # NPC
  private PADDIES = 32378
  # Locations
  private RUNE_TOWNSHIP = Location.new(43835, -47749, -792)
  private RETURN_LOCATIONS = {
    Location.new(-80826, 149775, -3043),
    Location.new(-12672, 122776, -3116),
    Location.new(15670, 142983, -2705),
    Location.new(83400, 147943, -3404),
    Location.new(111409, 219364, -3545),
    Location.new(82956, 53162, -1495),
    Location.new(146331, 25762, -2018),
    Location.new(116819, 76994, -2714),
    Location.new(43835, -47749, -792),
    Location.new(147930, -55281, -2728),
    Location.new(87386, -143246, -1293),
    Location.new(12882, 181053, -3560)
  }
  private ISLE_LOCATIONS = {
    Location.new(-58752, -56898, -2032),
    Location.new(-59716, -57868, -2032),
    Location.new(-60691, -56893, -2032),
    Location.new(-59720, -55921, -2032)
  }
  # Misc
  private TELEPORTERS = {
    30059 => 2, # Trisha
    30080 => 3, # Clarissa
    30177 => 5, # Valentina
    30233 => 7, # Esmeralda
    30256 => 1, # Bella
    30320 => 0, # Richlin
    30848 => 6, # Elisa
    30899 => 4, # Flauen
    31320 => 8, # Ilyana
    31275 => 9, # Tatiana
    31964 => 10 # Bilia
  }
  # Player Variables
  private FANTASY_RETURN = "FANTASY_RETURN"

  def initialize
    super(self.class.simple_name, "ai/npc/Teleports")

    add_start_npc(PADDIES)
    add_start_npc(TELEPORTERS.keys)
    add_talk_id(PADDIES)
    add_talk_id(TELEPORTERS.keys)
  end

  def on_talk(npc, pc)
    if npc.id == PADDIES
      return_id = pc.variables.get_i32(FANTASY_RETURN, -1)
      if return_id != -1
        pc.tele_to_location(RETURN_LOCATIONS[return_id])
        pc.variables.delete(FANTASY_RETURN)
      else
        broadcast_npc_say(npc, Say2::ALL, NpcString::IF_YOUR_MEANS_OF_ARRIVAL_WAS_A_BIT_UNCONVENTIONAL_THEN_ILL_BE_SENDING_YOU_BACK_TO_RUNE_TOWNSHIP_WHICH_IS_THE_NEAREST_TOWN)
        pc.tele_to_location(RUNE_TOWNSHIP)
      end
    else
      pc.tele_to_location(ISLE_LOCATIONS.sample)
      pc.variables[FANTASY_RETURN] = TELEPORTERS[npc.id]
    end

    super
  end
end
