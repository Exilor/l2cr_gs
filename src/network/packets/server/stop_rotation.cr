class Packets::Outgoing::StopRotation < GameServerPacket
  initializer id : Int32, degree : Int32, speed : Int32

  private def write_impl
    c 0x61

    d @id
    d @degree
    d @speed
    c 0 # unknown to L2J
  end
end
