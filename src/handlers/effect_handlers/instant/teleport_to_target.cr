class EffectHandler::TeleportToTarget < AbstractEffect
  def on_start(info : BuffInfo)
    char = info.effector
    target = info.effected

    px, py = target.x, target.y
    ph = Util.convert_heading_to_degree(target.heading)
    ph += 180
    ph -= 360 if ph > 360
    ph = (Math::PI * ph) / 180
    x = (px + (25 * Math.cos(ph))).to_i
    y = (py + (25 * Math.sin(ph))).to_i
    z = target.z

    loc = GeoData.move_check(*char.xyz, x, y, z, char.instance_id)

    char.intention = AI::IDLE
    ftl = FlyToLocation.new(char, *loc.xyz, FlyType::DUMMY)
    char.broadcast_packet(ftl)
    char.abort_attack
    char.abort_cast
    char.set_xyz(loc)
    char.broadcast_packet(ValidateLocation.new(char))
  end

  def instant? : Bool
    true
  end
end
