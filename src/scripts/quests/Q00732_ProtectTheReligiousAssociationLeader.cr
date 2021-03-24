class Q00732_ProtectTheReligiousAssociationLeader < TerritoryWarSuperClass
  def initialize
    super(732, self.class.simple_name, "Protect the Religious Association Leader")

    @npc_ids = [
      36510,
      36516,
      36522,
      36528,
      36534,
      36540,
      36546,
      36552,
      36558
    ]

    add_attack_id(@npc_ids)
  end

  def get_territory_id_for_this_npc_id(npc_id : Int32) : Int32
    81 &+ ((npc_id &- 36510) // 6)
  end
end
