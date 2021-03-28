class EffectHandler::SingleTarget < AbstractEffect
  def effect_flags : UInt32
    EffectFlag::SINGLE_TARGET.mask
  end
end
