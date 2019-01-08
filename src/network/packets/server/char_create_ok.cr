class Packets::Outgoing::CharCreateOk < GameServerPacket
  static_packet

  def write_impl
    c 0x0f
    d 0x01
  end
end
