class EffectHandler::TickHp < AbstractEffect
  @power : Float64
  @mode : EffectCalculationType

  def initialize(attach_cond, apply_cond, set, params)
    super

    @power = params.get_f64("power", 0)
    @mode = params.get_enum("mode", EffectCalculationType, EffectCalculationType::DIFF)
    @ticks = params.get_i32("ticks")
  end

  def effect_type
    L2EffectType::DMG_OVER_TIME
  end

  def on_start(info)
    target = info.effected
    skill = info.skill

    if target.player? && @ticks > 0 && skill.abnormal_type.hp_recover?
      target.send_packet(ExRegenMax.new(info.abnormal_time, @ticks, @power))
    end
  end

  def on_action_time(info) : Bool
    target = info.effected
    return false if target.dead?

    hp = target.current_hp

    if @mode.diff?
      power = @power * ticks_multiplier
    else
      power = hp * @power * ticks_multiplier
    end

    if power < 0
      power = power.abs

      if power > target.current_hp - 1
        power = target.current_hp - 1
      end

      target.reduce_current_hp_by_dot(power, info.effector, info.skill)
      target.notify_damage_received(power, info.effector, info.skill, false, true, false)
    else
      max_hp = target.max_recoverable_hp

      if hp > max_hp
        return true
      end

      target.current_hp = Math.min(hp + power, max_hp).to_f64
    end

    false
  end
end
