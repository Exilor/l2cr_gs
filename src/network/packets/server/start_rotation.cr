class Packets::Outgoing::StartRotation < GameServerPacket
  initializer id : Int32, degree : Int32, side : Int32, speed : Int32

  private def write_impl
    c 0x7a

    d @id
    d @degree
    d @side
    d @speed
  end
end
