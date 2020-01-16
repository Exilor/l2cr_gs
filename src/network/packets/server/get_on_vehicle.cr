class Packets::Outgoing::GetOnVehicle < GameServerPacket
  initializer pc_id : Int32, boat_id : Int32, pos : Location

  private def write_impl
    c 0x6e

    d @pc_id
    d @boat_id
    l @pos
  end
end
