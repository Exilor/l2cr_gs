class EffectHandler::SilentMove < AbstractEffect
  def effect_flags
    EffectFlag::SILENT_MOVE.mask
  end
end
