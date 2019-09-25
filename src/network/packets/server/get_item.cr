class Packets::Outgoing::GetItem < GameServerPacket
  initializer item : L2ItemInstance, player_id : Int32

  def write_impl
    c 0x17

    d @player_id
    d @item.l2id
    l @item
  end
end
