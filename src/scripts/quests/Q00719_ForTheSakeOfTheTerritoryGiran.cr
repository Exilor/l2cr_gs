class Q00719_ForTheSakeOfTheTerritoryGiran < TerritoryWarSuperClass
  def initialize
    super(719, self.class.simple_name, "For the Sake of the Territory - Giran")

    @catapult_id = 36501
    @territory_id = 83
    @leader_ids = [
      36520,
      36522,
      36525,
      36593
    ]
    @guard_ids = [
      36521,
      36523,
      36524
    ]
    @npc_string = [
      NpcString::THE_CATAPULT_OF_GIRAN_HAS_BEEN_DESTROYED
    ]

    register_kill_ids
  end
end
