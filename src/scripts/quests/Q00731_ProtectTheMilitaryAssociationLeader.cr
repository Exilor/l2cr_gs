class Q00731_ProtectTheMilitaryAssociationLeader < TerritoryWarSuperClass
  def initialize
    super(731, self.class.simple_name, "Protect the Military Association Leader")

    @npc_ids = [
      36508,
      36514,
      36520,
      36526,
      36532,
      36538,
      36544,
      36550,
      36556
    ]

    add_attack_id(@npc_ids)
  end

  def get_territory_id_for_this_npc_id(npc_id : Int32) : Int32
    81 &+ ((npc_id &- 36508) // 6)
  end
end
