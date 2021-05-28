class EffectHandler::ConsumeMp < AbstractEffect
  @power : Float64

  def initialize(attach_cond : Condition?, apply_cond : Condition?, set : StatsSet, params : StatsSet)
    super

    @power = params.get_f64("power", 0)
    @ticks = params.get_i32("ticks")
  end

  def on_action_time(info : BuffInfo) : Bool
    return false if info.effected.dead?

    target = info.effected
    consume = @power * ticks_multiplier
    mp = target.current_mp
    if consume < 0 && mp + consume <= 0
      target.send_packet(SystemMessageId::SKILL_REMOVED_DUE_LACK_MP)
      return false
    end

    target.current_mp = Math.min(mp + consume, target.max_recoverable_mp).to_f64

    true
  end
end
