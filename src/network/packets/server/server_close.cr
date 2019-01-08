class Packets::Outgoing::ServerClose < GameServerPacket
  static_packet

  def write_impl
    c 0x20
  end
end
