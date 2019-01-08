class Packets::Outgoing::BlowfishKey < MMO::OutgoingPacket(LoginServerClient)
  def initialize(*args)
  end

  def write
    c 0x00
    d 128
    128.times { |i| c Rnd.u8 }
  end
end
