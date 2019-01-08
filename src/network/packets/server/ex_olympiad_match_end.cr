class Packets::Outgoing::ExOlympiadMatchEnd < GameServerPacket
  static_packet

  def write_impl
    c 0xfe
    h 0x2d
  end
end
