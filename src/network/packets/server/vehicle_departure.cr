class Packets::Outgoing::VehicleDeparture < GameServerPacket
  @l2id : Int32
  @x : Int32
  @y : Int32
  @z : Int32
  @move_speed : Int32
  @rotation_speed : Int32

  def initialize(boat : L2BoatInstance)
    @l2id = boat.l2id
    @x = boat.x_destination
    @y = boat.y_destination
    @z = boat.z_destination
    @move_speed = boat.move_speed.to_i
    @rotation_speed = boat.stat.rotation_speed.to_i
  end

  def write_impl
    c 0x6c

    d @l2id
    d @move_speed
    d @rotation_speed
    d @x
    d @y
    d @z
  end
end
