class Packets::Outgoing::ExCubeGameChangePoints < GameServerPacket
  initializer time_left : Int32, blue_points : Int32, red_points : Int32

  private def write_impl
    c 0xfe
    h 0x98

    d 0x02

    d @time_left
    d @blue_points
    d @red_points
  end
end
