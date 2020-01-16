class Packets::Outgoing::ExSearchOrc < GameServerPacket
  static_packet

  private def write_impl
    c 0xfe
    h 0x45
  end
end
