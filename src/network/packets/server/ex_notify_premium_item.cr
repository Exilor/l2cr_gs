class Packets::Outgoing::ExNotifyPremiumItem < GameServerPacket
  static_packet

  private def write_impl
    c 0xfe
    h 0x85
  end
end
