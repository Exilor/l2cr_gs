class EffectHandler::Fear < AbstractEffect
  def can_start?(info : BuffInfo) : Bool
    e = info.effected
    e.player? || e.summon? || (e.attackable? &&
    !(e.is_a?(L2DefenderInstance) || e.is_a?(L2FortCommanderInstance) ||
    e.is_a?(L2SiegeFlagInstance) || e.template.race.siege_weapon?))
  end

  def effect_flags
    EffectFlag::FEAR.mask
  end

  def effect_type : EffectType
    EffectType::FEAR
  end

  def ticks
    5
  end

  def on_action_time(info : BuffInfo) : Bool
    info.effected.notify_event(AI::AFRAID, info.effector, false)
    false
  end

  def on_start(info)
    target = info.effected
    if target.casting_now? && target.can_abort_cast?
      target.abort_cast
    end

    target.notify_event(AI::AFRAID, info.effector, true)
  end
end
