class EffectHandler::PhysicalMute < AbstractEffect
  def effect_flags
    EffectFlag::PHYSICAL_MUTED.mask
  end

  def on_start(info)
    info.effected.notify_event(AI::MUTED)
  end
end
