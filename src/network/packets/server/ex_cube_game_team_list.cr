class Packets::Outgoing::ExCubeGameTeamList < GameServerPacket
  initializer red_players : Array(L2PcInstance),
    blue_players : Array(L2PcInstance), room_number : Int32

  def write_impl
    c 0xfe
    h 0x97

    d 0x00

    d @room_number - 1
    d 0xffffffff

    d @blue_players.size
    @blue_players.each do |pc|
      d pc.l2id
      s pc.name
    end

    d @red_players.size
    @red_players.each do |pc|
      d pc.l2id
      s pc.name
    end
  end
end
