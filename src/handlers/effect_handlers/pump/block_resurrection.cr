class EffectHandler::BlockResurrection < AbstractEffect
  def effect_flags : UInt32
    EffectFlag::BLOCK_RESURRECTION.mask
  end
end
