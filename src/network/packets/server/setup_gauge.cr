class Packets::Outgoing::SetupGauge < GameServerPacket
  @char_id = 0

  private initializer color : UInt8, now : Int32, max : Int32 = now

  def self.blue(*args)
    new(0, *args)
  end

  def self.red(*args)
    new(1, *args)
  end

  def self.cyan(*args)
    new(2, *args)
  end

  def self.green(*args)
    new(3, *args)
  end

  def run_impl
    @char_id = client.active_char.not_nil!.l2id
  end

  private def write_impl
    c 0x6b

    d @char_id
    d @color
    d @now
    d @max
  end
end
