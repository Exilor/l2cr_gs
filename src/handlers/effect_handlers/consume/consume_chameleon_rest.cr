class EffectHandler::ConsumeChameleonRest < AbstractEffect
  @power : Float64

  def initialize(attach_cond, apply_cond, set, params)
    super

    @power = params.get_f64("power", 0)
    @ticks = params.get_i32("ticks")
  end

  def effect_type
    L2EffectType::RELAXING
  end

  def on_start(info)
    if info.effected.player?
      info.effected.acting_player.sit_down(false)
    else
      info.effected.set_intention(AI::REST)
    end
  end

  def on_action_time(info)
    target = info.effected
    return false if target.dead?

    if target.player?
      return false unless target.acting_player.sitting?
    end

    mana_dam = @power * ticks_multiplier

    if mana_dam < 0 && target.current_mp + mana_dam <= 0
      target.send_packet(SystemMessageId::SKILL_REMOVED_DUE_LACK_MP)
      return false
    end

    target.current_mp = Math.min(target.current_mp + mana_dam, target.max_recoverable_mp).to_f64

    true
  end

  def effect_flags
    EffectFlag::SILENT_MOVE.mask | EffectFlag::RELAXING.mask
  end
end
