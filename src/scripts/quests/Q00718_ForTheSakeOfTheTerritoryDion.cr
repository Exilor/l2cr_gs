class Q00718_ForTheSakeOfTheTerritoryDion < TerritoryWarSuperClass
  def initialize
    super(718, self.class.simple_name, "For the Sake of the Territory - Dion")

    @catapult_id = 36500
    @territory_id = 82
    @leader_ids = [
      36514,
      36516,
      36519,
      36592
    ]
    @guard_ids = [
      36515,
      36517,
      36518
    ]
    @npc_string = [
      NpcString::THE_CATAPULT_OF_DION_HAS_BEEN_DESTROYED
    ]

    register_kill_ids
  end
end
