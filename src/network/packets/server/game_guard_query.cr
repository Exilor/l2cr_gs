class Packets::Outgoing::GameGuardQuery < GameServerPacket
  static_packet

  private def write_impl
    c 0x74

    d 0x27533DD9
    d 0x2E72A51D
    d 0x2017038B
    d 0xC35B1EA3
  end
end
