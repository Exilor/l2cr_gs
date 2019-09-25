class Packets::Outgoing::ExRegenMax < GameServerPacket
  initializer time : Int32, tick_interval : Int32, amount_per_tick : Float64

  def write_impl
    c 0xfe
    h 0x01

    d 1
    d @time
    d @tick_interval
    f @amount_per_tick
  end
end
