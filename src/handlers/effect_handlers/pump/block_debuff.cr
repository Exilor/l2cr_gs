class EffectHandler::BlockDebuff < AbstractEffect
  def effect_flags : UInt32
    EffectFlag::BLOCK_DEBUFF.mask
  end
end
