class Packets::Outgoing::ShopPreviewInfo < GameServerPacket
  initializer items: Hash(Int32, Int32)

  def write_impl
    c 0xf6

    d Inventory::TOTALSLOTS

    d @items.fetch(Inventory::UNDER, 0)
    d @items.fetch(Inventory::REAR, 0)
    d @items.fetch(Inventory::LEAR, 0)
    d @items.fetch(Inventory::NECK, 0)
    d @items.fetch(Inventory::RFINGER, 0)
    d @items.fetch(Inventory::LFINGER, 0)
    d @items.fetch(Inventory::HEAD, 0)
    d @items.fetch(Inventory::RHAND, 0)
    d @items.fetch(Inventory::LHAND, 0)
    d @items.fetch(Inventory::GLOVES, 0)
    d @items.fetch(Inventory::CHEST, 0)
    d @items.fetch(Inventory::LEGS, 0)
    d @items.fetch(Inventory::FEET, 0)
    d @items.fetch(Inventory::CLOAK, 0)
    d @items.fetch(Inventory::RHAND, 0)
    d @items.fetch(Inventory::HAIR, 0)
    d @items.fetch(Inventory::HAIR2, 0)
    d @items.fetch(Inventory::RBRACELET, 0)
    d @items.fetch(Inventory::LBRACELET, 0)
  end
end
