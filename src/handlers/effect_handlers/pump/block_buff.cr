class EffectHandler::BlockBuff < AbstractEffect
  def effect_flags : UInt64
    EffectFlag::BLOCK_BUFF.mask
  end
end
