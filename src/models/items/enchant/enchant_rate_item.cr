class EnchantRateItem
  @slot = 0
  setter item_id : Int32 = 0
  setter magic_weapon : Bool?

  getter_initializer name : String

  def add_slot(slot : Int)
    @slot |= slot
  end

  def validate(item : L2Item) : Bool
    return false if @item_id != 0 && @item_id != item.id
    return false if @slot != 0 && item.body_part & @slot == 0
    return false if !@magic_weapon.nil? && item.magic_weapon? != @magic_weapon
    true
  end
end
