class Packets::Outgoing::Ex2ndPasswordAck < GameServerPacket
  SUCCESS = 0x00
  WRONG_PATTERN = 0x01

  initializer response : Int32

  def write_impl
    c 0xfe

    h 0xe7
    c 0x00
    d @response == WRONG_PATTERN ? 0x01 : 0x00
    d 0x00
  end
end
