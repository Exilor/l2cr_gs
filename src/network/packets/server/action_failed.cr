class Packets::Outgoing::ActionFailed < GameServerPacket
  static_packet

  private def write_impl
    c 0x1f
  end
end
