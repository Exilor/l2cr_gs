class EffectHandler::Paralyze < AbstractEffect
  def effect_flags
    EffectFlag::PARALYZED.mask
  end

  def effect_type
    L2EffectType::PARALYZE
  end

  def on_exit(info)
    unless info.effected.player?
      info.effected.notify_event(AI::THINK)
    end
  end

  def on_start(info)
    # AI#on_intention_idle doesn't take an arg but L2J wrote it that way.
    info.effected.intention = AI::IDLE
    info.effected.start_paralyze
  end
end
