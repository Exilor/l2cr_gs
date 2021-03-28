class EffectHandler::SilentMove < AbstractEffect
  def effect_flags : UInt32
    EffectFlag::SILENT_MOVE.mask
  end
end
