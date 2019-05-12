class Q00725_ForTheSakeOfTheTerritorySchuttgart < TerritoryWarSuperClass
  def initialize
    super(725, self.class.simple_name, "For the Sake of the Territory - Schuttgart")

    @catapult_id = 36507
    @territory_id = 89
    @leader_ids = [
      36556,
      36558,
      36561,
      36599
    ]
    @guard_ids = [
      36557,
      36559,
      36560
    ]
    @npc_string = [
      NpcString::THE_CATAPULT_OF_SCHUTTGART_HAS_BEEN_DESTROYED
    ]

    register_kill_ids
  end
end
