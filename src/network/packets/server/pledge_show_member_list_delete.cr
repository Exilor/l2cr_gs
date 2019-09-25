class Packets::Outgoing::PledgeShowMemberListDelete < GameServerPacket
  initializer player_name : String

  def write_impl
    c 0x5d
    s @player_name
  end
end
