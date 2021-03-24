class Packets::Outgoing::ClientSetTime < GameServerPacket
  @time : Int32? = GameTimer.time
  @speed = 6

  initializer
  initializer time : Int32?
  initializer time : Int32, speed : Int32

  def initialize(time : String, speed : Int32 = 6)
    @speed = speed
    hh, mm = time.split(':')
    @time = (hh.to_i &* 60) &+ mm.to_i
  end

  private def write_impl
    c 0xf2

    d @time || GameTimer.time
    d @speed
  end

  STATIC_PACKET = new(time: nil)
end
