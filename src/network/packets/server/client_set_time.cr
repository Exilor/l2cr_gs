class Packets::Outgoing::ClientSetTime < GameServerPacket
  @time = GameTimer.time
  @speed = 6

  def initialize(@time : Int32, @speed : Int32)
  end

  def initialize(@time : Int32)
  end

  def initialize
  end

  def initialize(time : String, @speed : Int32 = 6)
    hh, mm = time.split(':').map &.to_i
    @time = (hh * 60) + mm
  end

  private def write_impl
    c 0xf2

    d @time
    d @speed
  end
end
