class EffectHandler::ConsumeRest < AbstractEffect
  @power : Float64

  def initialize(attach_cond, apply_cond, set, params)
    super

    @power = params.get_f64("power", 0)
    @ticks = params.get_i32("ticks")
  end

  def effect_flags
    EffectFlag::RELAXING.mask
  end

  def effect_type : EffectType
    EffectType::RELAXING
  end

  def on_action_time(info : BuffInfo) : Bool
    target = info.effected
    return false if target.dead?

    if target.is_a?(L2PcInstance) && !target.sitting?
      return false
    end

    if target.current_hp + 1 > target.max_recoverable_hp
      target.send_packet(SystemMessageId::SKILL_DEACTIVATED_HP_FULL)
      return false
    end

    consume = @power * ticks_multiplier
    mp = target.current_mp
    if consume < 0 && mp + consume <= 0
      target.send_packet(SystemMessageId::SKILL_REMOVED_DUE_LACK_MP)
      return false
    end

    target.current_mp = Math.min(mp + consume, target.max_recoverable_mp).to_f64

    true
  end

  def on_start(info)
    if pc = info.effected.as?(L2PcInstance)
      pc.sit_down(false)
    else
      info.effected.intention = AI::REST
    end
  end
end
