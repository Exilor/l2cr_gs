class EffectHandler::BlockBuff < AbstractEffect
  def effect_flags
    EffectFlag::BLOCK_BUFF.mask
  end
end
