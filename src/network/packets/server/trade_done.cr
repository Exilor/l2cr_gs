class Packets::Outgoing::TradeDone < GameServerPacket
  private initializer num : Int8

  private def write_impl
    c 0x1c
    d @num
  end

  CANCEL = new(0)
  ACCEPT = new(1)
end
