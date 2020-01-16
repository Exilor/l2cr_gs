class Scripts::DelusionTeleport < AbstractNpcAI
  # NPCs
  private NPCS = {
    32484, # Pathfinder Worker
    32658, # Guardian of Eastern Seal
    32659, # Guardian of Western Seal
    32660, # Guardian of Southern Seal
    32661, # Guardian of Northern Seal
    32662, # Guardian of Great Seal
    32663  # Guardian of Tower of Seal
  }
  # Location
  private HALL_LOCATIONS = {
    Location.new(-114597, -152501, -6750),
    Location.new(-114589, -154162, -6750)
  }
  # Player Variables
  private DELUSION_RETURN = "DELUSION_RETURN"

  private RETURN_LOCATIONS = {
    0 => Location.new(43835, -47749, -792),    # Undefined origin, return to Rune
    7 => Location.new(-14023, 123677, -3112),  # Gludio
    8 => Location.new(18101, 145936, -3088),   # Dion
    10 => Location.new(80905, 56361, -1552),   # Oren
    14 => Location.new(42772, -48062, -792),   # Rune
    15 => Location.new(108469, 221690, -3592), # Heine
    17 => Location.new(85991, -142234, -1336)  # Schuttgart
  }

  def initialize
    super(self.class.simple_name, "ai/npc/Teleports")

    add_start_npc(NPCS)
    add_talk_id(NPCS)
  end

  def on_talk(npc, pc)
    if npc.id == NPCS[0]
      town = TownManager.get_town(*npc.xyz)
      town_id = town ? town.town_id : 0
      pc.variables[DELUSION_RETURN] = town_id
      pc.tele_to_location(HALL_LOCATIONS.sample(random: Rnd), false)
    else
      town_id = pc.variables.get_i32(DELUSION_RETURN, 0)
      pc.tele_to_location(RETURN_LOCATIONS[town_id], true)
      pc.variables.delete(DELUSION_RETURN)
    end

    super
  end
end
