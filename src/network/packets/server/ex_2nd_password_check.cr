class Packets::Outgoing::Ex2ndPasswordCheck < GameServerPacket
  private initializer window_type : UInt8

  private def write_impl
    c 0xfe

    h 0xe5
    d @window_type
    d 0x00
  end

  NEW = new(0)
  PROMPT = new(1)
  OK = new(2)
end
