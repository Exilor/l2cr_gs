class Packets::Outgoing::ExCubeGameChangeTimeToStart < GameServerPacket
  initializer seconds : Int32

  private def write_impl
    c 0xfe
    h 0x97

    d 0x03

    d @seconds
  end
end
