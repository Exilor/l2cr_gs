class Packets::Outgoing::SurrenderPledgeWar < GameServerPacket
  initializer pledge_name: String, player_name: String

  def write_impl
    c 0x67

    s @pledge_name
    s @player_name
  end
end
