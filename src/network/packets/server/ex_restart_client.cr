class Packets::Outgoing::ExRestartClient < GameServerPacket
  static_packet

  private def write_impl
    c 0xfe
    h 0x48
  end
end
