class Packets::Outgoing::ActionFailed < GameServerPacket
  static_packet

  def write_impl
    c 0x1f
  end
end
