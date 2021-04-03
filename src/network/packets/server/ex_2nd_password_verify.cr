class Packets::Outgoing::Ex2ndPasswordVerify < GameServerPacket
  private initializer mode : UInt8, wrong_tentatives : Int32

  def self.ok(wrong_tentatives : Int32) : self
    new(0, wrong_tentatives)
  end

  def self.wrong(wrong_tentatives : Int32) : self
    new(1, wrong_tentatives)
  end

  def self.ban(wrong_tentatives : Int32) : self
    new(2, wrong_tentatives)
  end

  private def write_impl
    c 0xfe
    h 0xe6
    d @mode
    d @wrong_tentatives
  end
end
