class EffectHandler::Teleport < AbstractEffect
  def initialize(attach_cond, apply_cond, set, params)
    super

    x = params.get_i32("x", 0)
    y = params.get_i32("y", 0)
    z = params.get_i32("z", 0)
    @loc = Location.new(x, y, z)
  end

  def effect_type : EffectType
    EffectType::TELEPORT
  end

  def instant? : Bool
    true
  end

  def on_start(info)
    info.effected.tele_to_location(@loc, true)
  end
end
