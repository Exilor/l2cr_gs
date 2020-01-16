class Packets::Outgoing::ExClosePartyRoom < GameServerPacket
  static_packet

  private def write_impl
    c 0xfe
    h 0x09
  end
end
