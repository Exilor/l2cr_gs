class Packets::Outgoing::Ex2ndPasswordCheck < GameServerPacket
  PASSWORD_NEW = 0x00
  PASSWORD_PROMPT = 0x01
  PASSWORD_OK = 0x02

  initializer window_type: Int32

  def write_impl
    c 0xfe

    h 0xe5
    d @window_type
    d 0x00
  end
end
