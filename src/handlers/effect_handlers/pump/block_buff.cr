class EffectHandler::BlockBuff < AbstractEffect
  def effect_flags : UInt32
    EffectFlag::BLOCK_BUFF.mask
  end
end
