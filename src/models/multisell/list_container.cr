class Multisell::ListContainer
  getter entries = [] of Entry
  property use_rate : Float64 = 0.0
  property? apply_taxes : Bool = false
  property? maintain_enchantment : Bool = false

  getter_initializer list_id: Int32

  def allow_npc(npc_id : Int32)
    (@npcs_allowed ||= Set(Int32).new) << npc_id
  end

  def npc_allowed?(npc_id : Int32) : Bool
    return true unless temp = @npcs_allowed
    temp.includes?(npc_id)
  end

  def npc_only? : Bool
    !@npcs_allowed.nil?
  end
end
