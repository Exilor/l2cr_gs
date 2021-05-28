class EffectHandler::BlockDebuff < AbstractEffect
  def effect_flags : UInt64
    EffectFlag::BLOCK_DEBUFF.mask
  end
end
