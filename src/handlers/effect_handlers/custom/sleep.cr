class EffectHandler::Sleep < AbstractEffect
  def effect_flags
    EffectFlag::SLEEP.mask
  end

  def effect_type
    L2EffectType::SLEEP
  end

  def on_exit(info)
    unless info.effected.player?
      info.effected.notify_event(AI::THINK)
    end
  end

  def on_start(info)
    info.effected.abort_attack
    info.effected.abort_cast
    info.effected.stop_move
    info.effected.notify_event(AI::SLEEPING)
  end
end
