class EffectHandler::FlySelf < AbstractEffect
  @fly_radius : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super
    @fly_radius = params.get_i32("flyRadius", 0)
  end

  def instant?
    true
  end

  def on_start(info)
    effected =  info.effected
    return if effected.movement_disabled?
    effector = info.effector

    curx, cury, curz = effector.xyz

    dx = effected.x.to_f - curx
    dy = effected.y.to_f - cury
    dz = effected.z.to_f - curz

    distance = Math.hypot(dx, dy)
    if distance > 2000
      warn { "Charge distance is too large: #{distance}." }
      return
    end

    offset = Math.max(distance.to_i - @fly_radius, 30)

    offset -= dz.abs.to_i

    offset = 5 if offset < 5

    return if distance < 1 || distance - offset <= 0

    sin = dy / distance
    cos = dx / distance

    x = curx + ((distance - offset) * cos).to_i
    y = cury + ((distance - offset) * sin).to_i
    z = effected.z

    dst = GeoData.move_check(*effector.xyz, x, y, z, effector.instance_id)
    ftl = FlyToLocation.new(effector, dst, FlyType::CHARGE)
    effector.broadcast_packet(ftl)
    effector.broadcast_packet(ValidateLocation.new(effector))
  end
end
