class Packets::Outgoing::SunRise < GameServerPacket
  static_packet

  def write_impl
    c 0x12
  end
end
