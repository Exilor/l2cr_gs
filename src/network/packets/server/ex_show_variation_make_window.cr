class Packets::Outgoing::ExShowVariationMakeWindow < GameServerPacket
  static_packet

  private def write_impl
    c 0xfe
    h 0x51
  end
end
