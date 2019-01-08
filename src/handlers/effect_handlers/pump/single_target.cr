class EffectHandler::SingleTarget < AbstractEffect
  def effect_flags
    EffectFlag::SINGLE_TARGET.mask
  end
end
