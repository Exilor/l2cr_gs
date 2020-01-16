class EffectHandler::Root < AbstractEffect
  def effect_flags
    EffectFlag::ROOTED.mask
  end

  def effect_type : EffectType
    EffectType::ROOT
  end

  def on_start(info)
    info.effected.stop_move(nil)
    info.effected.notify_event(AI::ROOTED)
  end

  def on_exit(info)
    unless info.effected.player?
      info.effected.notify_event(AI::THINK)
    end
  end
end
