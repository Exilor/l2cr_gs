class EffectHandler::SingleTarget < AbstractEffect
  def effect_flags : UInt64
    EffectFlag::SINGLE_TARGET.mask
  end
end
