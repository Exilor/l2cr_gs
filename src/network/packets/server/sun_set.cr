class Packets::Outgoing::SunSet < GameServerPacket
  static_packet

  def write_impl
    c 0x13
  end
end
