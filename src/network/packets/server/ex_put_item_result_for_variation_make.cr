class Packets::Outgoing::ExPutItemResultForVariationMake < GameServerPacket
  initializer l2id: Int32, item_id: Int32

  def write_impl
    c 0xfe
    h 0x53

    d @l2id
    d @item_id
    d 0x01
  end
end
