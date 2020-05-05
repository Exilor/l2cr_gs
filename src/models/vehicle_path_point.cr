require "./location"

class VehiclePathPoint < Location
  getter move_speed, rotation_speed

  def initialize(x : Int32, y : Int32, z : Int32, move_speed : Int32 = 350, rotation_speed : Int32 = 4000)
    @x = x
    @y = y
    @z = z
    @move_speed = move_speed
    @rotation_speed = rotation_speed
    @heading = 0
    @instance_id = -1
  end
end
