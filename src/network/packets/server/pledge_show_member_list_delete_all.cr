class Packets::Outgoing::PledgeShowMemberListDeleteAll < GameServerPacket
  static_packet

  def write_impl
    c 0x88
  end
end
