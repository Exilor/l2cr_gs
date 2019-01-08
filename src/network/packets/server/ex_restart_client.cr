class Packets::Outgoing::ExRestartClient < GameServerPacket
  static_packet

  def write_impl
    c 0xfe
    h 0x48
  end
end
