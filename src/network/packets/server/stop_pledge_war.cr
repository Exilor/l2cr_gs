class Packets::Outgoing::StopPledgeWar < GameServerPacket
  initializer pledge_name : String, player_name : String

  private def write_impl
    c 0x65

    s @pledge_name
    s @player_name
  end
end
