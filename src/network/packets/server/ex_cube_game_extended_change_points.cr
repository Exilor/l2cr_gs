class Packets::Outgoing::ExCubeGameExtendedChangePoints < GameServerPacket
  initializer time_left : Int32, blue_points : Int32, red_points : Int32,
    red_team : Bool, pc : L2PcInstance, player_points : Int32

  private def write_impl
    c 0xfe
    h 0x98

    d 0

    d @time_left
    d @blue_points
    d @red_points

    d @red_team ? 1 : 0
    d @pc.l2id
    d @player_points
  end
end
