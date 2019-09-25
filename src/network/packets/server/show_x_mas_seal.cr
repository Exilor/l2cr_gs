class Packets::Outgoing::ShowXMasSeal < GameServerPacket
  initializer item_id : Int32

  def write_impl
    c 0xf8
    d @item_id
  end
end
