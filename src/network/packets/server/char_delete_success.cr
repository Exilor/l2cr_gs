class Packets::Outgoing::CharDeleteSuccess < GameServerPacket
  static_packet

  private def write_impl
    c 0x1d
  end
end
