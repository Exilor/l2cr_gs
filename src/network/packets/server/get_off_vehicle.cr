class Packets::Outgoing::GetOffVehicle < GameServerPacket
  initializer pc_id : Int32, boat_id : Int32, x : Int32, y : Int32, z : Int32

  def write_impl
    c 0x6f

    d @pc_id
    d @boat_id
    d @x
    d @y
    d @z
  end
end
