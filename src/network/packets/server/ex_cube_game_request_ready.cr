class Packets::Outgoing::ExCubeGameRequestReady < GameServerPacket
  static_packet

  def write_impl
    c 0xfe
    h 0x97

    d 0x04
  end
end
