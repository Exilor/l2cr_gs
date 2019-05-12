class Q00722_ForTheSakeOfTheTerritoryInnadril < TerritoryWarSuperClass
  def initialize
    super(722, self.class.simple_name, "For the Sake of the Territory - Innadril")

    @catapult_id = 36504
    @territory_id = 86
    @leader_ids = [
      36538,
      36540,
      36543,
      36596
    ]
    @guard_ids = [
      36539,
      36541,
      36542
    ]
    @npc_string = [
      NpcString::THE_CATAPULT_OF_INNADRIL_HAS_BEEN_DESTROYED
    ]

    register_kill_ids
  end
end
