class Packets::Outgoing::LeaveWorld < GameServerPacket
  static_packet

  def write_impl
    c 0x84
  end
end
