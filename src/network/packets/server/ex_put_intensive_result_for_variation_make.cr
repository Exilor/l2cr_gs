class Packets::Outgoing::ExPutIntensiveResultForVariationMake < GameServerPacket
  initializer refiner_item_obj_id: Int32, life_stone_id: Int32,
    gemstone_item_id: Int32, gemstone_count: Int32

  def write_impl
    c 0xfe
    h 0x54

    d @refiner_item_obj_id
    d @life_stone_id
    d @gemstone_item_id
    q @gemstone_count
    d 1#@unk2
  end
end
