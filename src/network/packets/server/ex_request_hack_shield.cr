class Packets::Outgoing::ExRequestHackShield < GameServerPacket
  static_packet

  private def write_impl
    c 0xfe
    h 0x49
  end
end
