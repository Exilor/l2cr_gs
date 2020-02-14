class EffectHandler::TickHpFatal < AbstractEffect
  @power : Float64
  @mode : EffectCalculationType

  def initialize(attach_cond, apply_cond, set, params)
    super

    @power = params.get_f64("power", 0)
    @mode = params.get_enum("mode", EffectCalculationType, EffectCalculationType::DIFF)
    @ticks = params.get_i32("ticks")
  end

  def effect_type : EffectType
    EffectType::DMG_OVER_TIME
  end

  def on_action_time(info : BuffInfo) : Bool
    target = info.effected
    return false if target.dead?

    if @mode.diff?
      damage = @power * ticks_multiplier
    else
      damage = target.current_hp * @power * ticks_multiplier
    end

    target.reduce_current_hp_by_dot(damage, info.effector, info.skill)
    target.notify_damage_received(damage, info.effector, info.skill, false, true, false)

    false
  end
end
