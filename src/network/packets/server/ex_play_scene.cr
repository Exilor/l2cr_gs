class Packets::Outgoing::ExPlayScene < GameServerPacket
  static_packet

  private def write_impl
    c 0xfe
    h 0x5c
  end
end
