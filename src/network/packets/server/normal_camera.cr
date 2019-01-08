class Packets::Outgoing::NormalCamera < GameServerPacket
  static_packet

  def write_impl
    c 0xd7
  end
end
