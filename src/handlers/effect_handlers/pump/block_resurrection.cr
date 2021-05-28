class EffectHandler::BlockResurrection < AbstractEffect
  def effect_flags : UInt64
    EffectFlag::BLOCK_RESURRECTION.mask
  end
end
