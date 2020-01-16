class Packets::Outgoing::ExDominionWarEnd < GameServerPacket
  static_packet

  private def write_impl
    c 0xfe
    h 0xa4
  end
end
