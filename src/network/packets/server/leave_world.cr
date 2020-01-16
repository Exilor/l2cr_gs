class Packets::Outgoing::LeaveWorld < GameServerPacket
  static_packet

  private def write_impl
    c 0x84
  end
end
