class EffectHandler::BlockDebuff < AbstractEffect
  def effect_flags
    EffectFlag::BLOCK_DEBUFF.mask
  end
end
