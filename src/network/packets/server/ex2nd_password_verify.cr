class Packets::Outgoing::Ex2ndPasswordVerify < GameServerPacket
  PASSWORD_OK = 0x00
  PASSWORD_WRONG = 0x01
  PASSWORD_BAN = 0x02

  initializer mode: Int32, wrong_tentatives: Int32

  def write_impl
    c 0xfe

    h 0xe6
    d @mode
    d @wrong_tentatives
  end
end
