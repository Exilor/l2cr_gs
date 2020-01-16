class Packets::Outgoing::ExShowVariationCancelWindow < GameServerPacket
  static_packet

  private def write_impl
    c 0xfe
    h 0x52
  end
end
