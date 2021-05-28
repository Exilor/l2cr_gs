class EffectHandler::TickMp < AbstractEffect
  @power : Float64
  @mode : EffectCalculationType

  def initialize(attach_cond : Condition?, apply_cond : Condition?, set : StatsSet, params : StatsSet)
    super

    @power = params.get_f64("power", 0)
    @mode = params.get_enum("mode", EffectCalculationType, EffectCalculationType::DIFF)
    @ticks = params.get_i32("ticks")
  end

  def on_action_time(info : BuffInfo) : Bool
    target = info.effected
    return false if target.dead?

    mp = target.current_mp

    if @mode.diff?
      power = @power * ticks_multiplier
    else
      power = mp * @power * ticks_multiplier
    end

    if power < 0
      target.reduce_current_mp(power.abs)
    else
      max_mp = target.max_recoverable_mp

      if mp >= max_mp
        return true
      end

      target.current_mp = Math.min(mp + power, max_mp).to_f64
    end

    false
  end
end
