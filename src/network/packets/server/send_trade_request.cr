class Packets::Outgoing::SendTradeRequest < GameServerPacket
  initializer id : Int32

  def write_impl
    c 0x70
    d @id
  end
end
