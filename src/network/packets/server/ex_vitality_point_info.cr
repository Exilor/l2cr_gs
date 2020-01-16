class Packets::Outgoing::ExVitalityPointInfo < GameServerPacket
  initializer points : Int32

  private def write_impl
    c 0xfe
    h 0xa0

    d @points
  end
end
