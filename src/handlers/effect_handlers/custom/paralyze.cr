class EffectHandler::Paralyze < AbstractEffect
  def effect_flags : UInt32
    EffectFlag::PARALYZED.mask
  end

  def effect_type : EffectType
    EffectType::PARALYZE
  end

  def on_exit(info : BuffInfo)
    unless info.effected.player?
      info.effected.notify_event(AI::THINK)
    end
  end

  def on_start(info : BuffInfo)
    info.effected.intention = AI::IDLE
    info.effected.start_paralyze
  end
end
