class EffectHandler::SilentMove < AbstractEffect
  def effect_flags : UInt64
    EffectFlag::SILENT_MOVE.mask
  end
end
