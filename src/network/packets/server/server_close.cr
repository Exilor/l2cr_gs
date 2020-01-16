class Packets::Outgoing::ServerClose < GameServerPacket
  static_packet

  private def write_impl
    c 0x20
  end
end
