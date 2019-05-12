require "./territory_war_super_class"

class Q00717_ForTheSakeOfTheTerritoryGludio < TerritoryWarSuperClass
  def initialize
    super(717, self.class.simple_name, "For the Sake of the Territory - Gludio")

    @catapult_id = 36499
    @territory_id = 81
    @leader_ids = [
      36508,
      36510,
      36513,
      36591
    ]
    @guard_ids = [
      36509,
      36511,
      36512
    ]
    @npc_string = [
      NpcString::THE_CATAPULT_OF_GLUDIO_HAS_BEEN_DESTROYED
    ]

    register_kill_ids
  end
end
