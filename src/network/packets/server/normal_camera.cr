class Packets::Outgoing::NormalCamera < GameServerPacket
  static_packet

  private def write_impl
    c 0xd7
  end
end
