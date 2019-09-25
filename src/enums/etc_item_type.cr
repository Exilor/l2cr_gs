require "../models/interfaces/item_type"

class EtcItemType < EnumClass
  include ItemType

  add(NONE)
  add(ARROW)
  add(POTION)
  add(SCRL_ENCHANT_WP)
  add(SCRL_ENCHANT_AM)
  add(SCROLL)
  add(RECIPE)
  add(MATERIAL)
  add(PET_COLLAR)
  add(CASTLE_GUARD)
  add(LOTTO)
  add(RACE_TICKET)
  add(DYE)
  add(SEED)
  add(CROP)
  add(MATURECROP)
  add(HARVEST)
  add(SEED2)
  add(TICKET_OF_LORD)
  add(LURE)
  add(BLESS_SCRL_ENCHANT_WP)
  add(BLESS_SCRL_ENCHANT_AM)
  add(COUPON)
  add(ELIXIR)
  add(SCRL_ENCHANT_ATTR)
  add(BOLT)
  add(SCRL_INC_ENCHANT_PROP_WP)
  add(SCRL_INC_ENCHANT_PROP_AM)
  add(ANCIENT_CRYSTAL_ENCHANT_WP)
  add(ANCIENT_CRYSTAL_ENCHANT_AM)
  add(RUNE_SELECT)
  add(RUNE)

  # L2J CUSTOM, BACKWARD COMPATIBILITY
  add(SHOT)

  def mask : UInt32
    0u32
  end
end
