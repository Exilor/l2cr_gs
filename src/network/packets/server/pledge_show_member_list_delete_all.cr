class Packets::Outgoing::PledgeShowMemberListDeleteAll < GameServerPacket
  static_packet

  private def write_impl
    c 0x88
  end
end
