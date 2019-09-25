class Packets::Outgoing::Earthquake < GameServerPacket
  initializer x : Int32, y : Int32, z : Int32, intensity : Int32,
    duration : Int32

  def write_impl
    c 0xd3

    d @x
    d @y
    d @z
    d @intensity
    d @duration
    d 0
  end
end
