class EffectHandler::Sleep < AbstractEffect
  def effect_flags : UInt32
    EffectFlag::SLEEP.mask
  end

  def effect_type : EffectType
    EffectType::SLEEP
  end

  def on_exit(info : BuffInfo)
    unless info.effected.player?
      info.effected.notify_event(AI::THINK)
    end
  end

  def on_start(info : BuffInfo)
    info.effected.abort_attack
    info.effected.abort_cast
    info.effected.stop_move(nil)
    info.effected.notify_event(AI::SLEEPING)
  end
end
