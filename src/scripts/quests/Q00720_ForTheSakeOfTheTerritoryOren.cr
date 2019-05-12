class Q00720_ForTheSakeOfTheTerritoryOren < TerritoryWarSuperClass
  def initialize
    super(720, self.class.simple_name, "For the Sake of the Territory - Oren")

    @catapult_id = 36502
    @territory_id = 84
    @leader_ids = [
      36526,
      36528,
      36531,
      36594
    ]
    @guard_ids = [
      36527,
      36529,
      36530
    ]
    @npc_string = [
      NpcString::THE_CATAPULT_OF_OREN_HAS_BEEN_DESTROYED
    ]

    register_kill_ids
  end
end
