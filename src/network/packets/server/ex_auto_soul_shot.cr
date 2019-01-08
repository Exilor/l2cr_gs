class Packets::Outgoing::ExAutoSoulShot < GameServerPacket
  initializer item_id: Int32, type: Int32

  def write_impl
    c 0xfe
    h 0x0c

    d @item_id
    d @type
  end
end
