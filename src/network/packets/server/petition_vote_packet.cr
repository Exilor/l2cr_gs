class Packets::Outgoing::PetitionVotePacket < GameServerPacket
  static_packet

  private def write_impl
    c 0xfc
  end
end
