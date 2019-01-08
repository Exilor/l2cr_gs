class Packets::Outgoing::ExPlayScene < GameServerPacket
  static_packet

  def write_impl
    c 0xfe
    h 0x5c
  end
end
