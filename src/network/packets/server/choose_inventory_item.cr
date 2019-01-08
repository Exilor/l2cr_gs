class Packets::Outgoing::ChooseInventoryItem < GameServerPacket
  initializer item_id: Int32

  def write_impl
    c 0x7c
    d @item_id
  end
end
