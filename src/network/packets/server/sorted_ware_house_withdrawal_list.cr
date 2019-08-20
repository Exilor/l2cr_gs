class Packets::Outgoing::SortedWareHouseWithdrawalList < GameServerPacket
  enum WarehouseListType : UInt8
    WEAPON
    ARMOR
    ETCITEM
    MATERIAL
    RECIPE
    AMULETT
    SPELLBOOK
    SHOT
    SCROLL
    CONSUMABLE
    SEED
    POTION
    QUEST
    PET
    OTHER
    ALL
  end

  # sort order A..Z
  A2Z = 1i8
  # sort order Z..A
  Z2A = -1i8
  # sort order Grade non..S
  GRADE = 2i8
  # sort order Recipe Level 1..9
  LEVEL = 3i8
  # sort order type
  TYPE = 4i8
  # sort order body part (wearing)
  WEAR = 5i8
  # Maximum Items to put into list
  MAX_SORT_LIST_ITEMS = 300

  def initialize(*a)
    debug "Not implemented." # it's very complicated and i suspect custom
  end

  def write_impl
    c 0x1f
  end

  def self.get_order(*args)
    0 #TODO
  end
end
