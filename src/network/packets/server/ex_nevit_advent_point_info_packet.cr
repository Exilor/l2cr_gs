class Packets::Outgoing::ExNevitAdventPointInfoPacket < GameServerPacket
  initializer points : Int32

  private def write_impl
    c 0xfe
    h 0xdf

    d @points
  end
end
