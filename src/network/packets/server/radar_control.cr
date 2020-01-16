class Packets::Outgoing::RadarControl < GameServerPacket
  initializer show_radar : Int32, type : Int32, x : Int32, y : Int32, z : Int32

  private def write_impl
    c 0xf1

    d @show_radar
    d @type
    d @x
    d @y
    d @z
  end
end
