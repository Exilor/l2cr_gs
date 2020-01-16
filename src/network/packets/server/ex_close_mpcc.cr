class Packets::Outgoing::ExCloseMPCC < GameServerPacket
  static_packet

  private def write_impl
    c 0xfe
    h 0x13
  end
end
