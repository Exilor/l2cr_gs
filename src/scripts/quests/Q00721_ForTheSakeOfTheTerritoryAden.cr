class Q00721_ForTheSakeOfTheTerritoryAden < TerritoryWarSuperClass
  def initialize
    super(721, self.class.simple_name, "For the Sake of the Territory - Aden")

    @catapult_id = 36503
    @territory_id = 85
    @leader_ids = [
      36532,
      36534,
      36537,
      36595
    ]
    @guard_ids = [
      36533,
      36535,
      36536
    ]
    @npc_string = [
      NpcString::THE_CATAPULT_OF_ADEN_HAS_BEEN_DESTROYED
    ]

    register_kill_ids
  end
end
