class Packets::Outgoing::PartySmallWindowDeleteAll < GameServerPacket
  static_packet

  private def write_impl
    c 0x50
  end
end
