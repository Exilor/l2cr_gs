class Q00733_ProtectTheEconomicAssociationLeader < TerritoryWarSuperClass
  def initialize
    super(733, self.class.simple_name, "Protect the Economic Association Leader")

    @npc_ids = [
      36513,
      36519,
      36525,
      36531,
      36537,
      36543,
      36549,
      36555,
      36561
    ]

    add_attack_id(@npc_ids)
  end

  def get_territory_id_for_this_npc_id(npc_id : Int32) : Int32
    81 + ((npc_id - 36513) // 6)
  end
end
