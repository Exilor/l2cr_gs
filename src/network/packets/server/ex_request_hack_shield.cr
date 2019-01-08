class Packets::Outgoing::ExRequestHackShield < GameServerPacket
  static_packet

  def write_impl
    c 0xfe
    h 0x49
  end
end
