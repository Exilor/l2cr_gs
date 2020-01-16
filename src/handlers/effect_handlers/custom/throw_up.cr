class EffectHandler::ThrowUp < AbstractEffect
  @fly_radius : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super
    @fly_radius = params.get_i32("flyRadius", 0)
  end

  def effect_flags
    EffectFlag::STUNNED.mask
  end

  def instant? : Bool
    true
  end

  def on_start(info)
    effected, effector = info.effected, info.effector

    cur_x, cur_y, cur_z = effected.xyz

    dx = effector.x - cur_x
    dy = effector.y - cur_y
    dz = effector.z - cur_z
    dist = Math.hypot(dx, dy)
    if dist > 2000
      warn "Invalid coordinates"
      return
    end

    offset = Math.min(dist + @fly_radius, 1400).to_i

    offset += dz.abs

    if offset < 5
      offset = 5
    end

    return if dist < 1

    sin = dy / dist
    cos = dx / dist

    x = effector.x - (offset * cos).to_i
    y = effector.y - (offset * sin).to_i
    z = effected.z

    dst = GeoData.move_check(*effected.xyz, x, y, z, effected.instance_id)
    ftl = FlyToLocation.new(effected, dst, FlyType::THROW_UP)
    effected.broadcast_packet(ftl)
    effected.set_xyz(dst)
    effected.broadcast_packet(ValidateLocation.new(effected))
  end
end
