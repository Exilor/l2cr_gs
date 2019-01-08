class Packets::Outgoing::ExNotifyPremiumItem < GameServerPacket
  static_packet

  def write_impl
    c 0xfe
    h 0x85
  end
end
