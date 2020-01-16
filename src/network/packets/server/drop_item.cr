class Packets::Outgoing::DropItem < GameServerPacket
  initializer item : L2ItemInstance, char_id : Int32

  private def write_impl
    c 0x16

    d @char_id
    d @item.l2id
    d @item.display_id
    l @item
    d @item.stackable? ? 1 : 0

    q @item.count

    d 0x01
  end
end
