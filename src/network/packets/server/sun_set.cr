class Packets::Outgoing::SunSet < GameServerPacket
  static_packet

  private def write_impl
    c 0x13
  end
end
