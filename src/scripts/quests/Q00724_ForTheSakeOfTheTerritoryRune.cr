class Q00724_ForTheSakeOfTheTerritoryRune < TerritoryWarSuperClass
  def initialize
    super(724, self.class.simple_name, "For the Sake of the Territory - Rune")

    @catapult_id = 36506
    @territory_id = 88
    @leader_ids = [
      36550,
      36552,
      36555,
      36598
    ]
    @guard_ids = [
      36551,
      36553,
      36554
    ]
    @npc_string = [
      NpcString::THE_CATAPULT_OF_RUNE_HAS_BEEN_DESTROYED
    ]

    register_kill_ids
  end
end
