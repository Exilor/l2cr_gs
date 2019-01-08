class Packets::Outgoing::CharDeleteSuccess < GameServerPacket
  static_packet

  def write_impl
    c 0x1d
  end
end
