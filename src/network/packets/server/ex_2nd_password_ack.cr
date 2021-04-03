class Packets::Outgoing::Ex2ndPasswordAck < GameServerPacket
  private initializer response : UInt8

  private def write_impl
    c 0xfe

    h 0xe7
    c 0x00
    d @response
    d 0x00
  end

  SUCCESS = new(0)
  WRONG = new(1)
end
