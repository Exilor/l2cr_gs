class EffectHandler::Mute < AbstractEffect
  def effect_flags : UInt32
    EffectFlag::MUTED.mask
  end

  def effect_type : EffectType
    EffectType::MUTE
  end

  def on_start(info : BuffInfo)
    info.effected.abort_cast
    info.effected.notify_event(AI::MUTED)
  end
end
