require "../models/interfaces/item_type"

class ArmorType < EnumClass
  include ItemType

  def mask : UInt32
    1u32 << (to_i + WeaponType.size)
  end

  add(NONE)
  add(LIGHT)
  add(HEAVY)
  add(MAGIC)
  add(SIGIL)
  add(SHIELD)
end
