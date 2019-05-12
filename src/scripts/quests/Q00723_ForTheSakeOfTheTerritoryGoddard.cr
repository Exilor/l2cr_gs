class Q00723_ForTheSakeOfTheTerritoryGoddard < TerritoryWarSuperClass
  def initialize
    super(723, self.class.simple_name, "For the Sake of the Territory - Goddard")

    @catapult_id = 36505
    @territory_id = 87
    @leader_ids = [
      36544,
      36546,
      36549,
      36597
    ]
    @guard_ids = [
      36545,
      36547,
      36548
    ]
    @npc_string = [
      NpcString::THE_CATAPULT_OF_GODDARD_HAS_BEEN_DESTROYED
    ]

    register_kill_ids
  end
end
