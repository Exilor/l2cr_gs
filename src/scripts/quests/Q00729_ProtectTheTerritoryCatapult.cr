class Q00729_ProtectTheTerritoryCatapult < TerritoryWarSuperClass
  def initialize
    super(729, self.class.simple_name, "Protect the Territory Catapult")

    @npc_ids = [
      36499,
      36500,
      36501,
      36502,
      36503,
      36504,
      36505,
      36506,
      36507
    ]

    add_attack_id(@npc_ids)
  end

  def get_territory_id_for_this_npc_id(npc_id : Int32) : Int32
    npc_id - 36418
  end
end
