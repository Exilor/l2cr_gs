class Packets::Outgoing::ExOpenMPCC < GameServerPacket
  static_packet

  def write_impl
    c 0xfe
    h 0x12
  end
end
