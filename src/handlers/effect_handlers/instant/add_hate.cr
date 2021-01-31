class EffectHandler::AddHate < AbstractEffect
  @power : Float64

  def initialize(attach_cond, apply_cond, set, params)
    super
    @power = params.get_f64("power", 0)
  end

  def instant? : Bool
    true
  end

  def on_start(info : BuffInfo)
    return unless mob = info.effected.as?(L2Attackable)

    val = @power.to_i64

    if val > 0
      mob.add_damage_hate(info.effector, 0, val)
    elsif val < 0
      mob.reduce_hate(info.effector, -val)
    end
  end
end
