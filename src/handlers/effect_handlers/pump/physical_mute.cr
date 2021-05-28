class EffectHandler::PhysicalMute < AbstractEffect
  def effect_flags : UInt64
    EffectFlag::PHYSICAL_MUTED.mask
  end

  def on_start(info : BuffInfo)
    info.effected.notify_event(AI::MUTED)
  end
end
