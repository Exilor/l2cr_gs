class ItemType1 < EnumClass
  getter id
  protected initializer id: Int32

  add(WEAPON_RING_EARRING_NECKLACE, 0)
  add(SHIELD_ARMOR, 1)
  add(ITEM_QUESTITEM_ADENA, 4)
end
