class EffectHandler::ConsumeHp < AbstractEffect
  @power : Float64

  def initialize(attach_cond, apply_cond, set, params)
    super

    @power = params.get_f64("power", 0)
    @ticks = params.get_i32("ticks")
  end

  def on_action_time(info)
    return false if info.effected.dead?

    target = info.effected
    consume = @power * ticks_multiplier
    hp = target.current_hp
    if consume < 0 && hp + consume <= 0
      target.send_packet(SystemMessageId::SKILL_REMOVED_DUE_LACK_HP)
      return false
    end

    target.current_hp = Math.min(hp + consume, target.max_recoverable_hp).to_f64

    true
  end
end
