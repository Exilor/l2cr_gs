class Packets::Outgoing::StartPledgeWar < GameServerPacket
  initializer pledge_name: String, player_name: String

  def write_impl
    c 0x63

    s @player_name
    s @pledge_name
  end
end
