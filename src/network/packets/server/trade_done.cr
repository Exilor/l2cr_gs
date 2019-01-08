class Packets::Outgoing::TradeDone < GameServerPacket
  private initializer num: Int8

  def write_impl
    c 0x1c
    d @num
  end

  ZERO = new(0)
  ONE  = new(1)
end
