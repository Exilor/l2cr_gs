class Packets::Outgoing::ExMailArrived < GameServerPacket
  static_packet

  private def write_impl
    c 0xfe
    h 0x2e
  end
end
