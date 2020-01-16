# class ItemType1 < EnumClass
#   getter id
#   protected initializer id : Int32

#   add(WEAPON_RING_EARRING_NECKLACE, 0)
#   add(SHIELD_ARMOR, 1)
#   add(ITEM_QUESTITEM_ADENA, 4)
# end

enum ItemType1 : UInt8
  WEAPON_RING_EARRING_NECKLACE, SHIELD_ARMOR, ITEM_QUESTITEM_ADENA

  def id : Int32
    weapon_ring_earring_necklace? ? 0 : shield_armor? ? 1 : 4
  end
end
