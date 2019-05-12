class Q00730_ProtectTheSuppliesSafe < TerritoryWarSuperClass
  def initialize
    super(730, self.class.simple_name, "Protect the Supplies Safe")

    @npc_ids = [
      36591,
      36592,
      36593,
      36594,
      36595,
      36596,
      36597,
      36598,
      36599
    ]

    add_attack_id(@npc_ids)
  end

  def get_territory_id_for_this_npc_id(npc_id : Int32) : Int32
    npc_id - 36510
  end
end
