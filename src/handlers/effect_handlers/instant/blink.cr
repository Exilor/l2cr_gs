class EffectHandler::Blink < AbstractEffect
  @fly_course : Int32
  @fly_radius : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super

    @fly_course = params.get_i32("flyCourse", 0)
    @fly_radius = params.get_i32("flyRadius", 0)
  end

  def instant?
    true
  end

  def on_start(info)
    char = info.effected
    angle = Util.convert_heading_to_degree(char.heading)
    radian = Math.to_radians(angle)
    course = Math.to_radians(@fly_course)
    x1 = (Math.cos(Math::PI + radian + course) * @fly_radius).to_i
    y1 = (Math.sin(Math::PI + radian + course) * @fly_radius).to_i

    x = char.x + x1
    y = char.y + y1
    z = char.z

    instance_id = char.instance_id

    dst = GeoData.move_check(*char.xyz, x, y, z, instance_id)
    char.intention = AI::IDLE
    ftl = FlyToLocation.new(char, dst, FlyType::DUMMY)
    char.broadcast_packet(ftl)
    char.abort_attack
    char.abort_cast
    char.set_xyz(dst)
    char.broadcast_packet(ValidateLocation.new(char))
  end
end
