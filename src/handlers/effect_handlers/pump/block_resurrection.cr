class EffectHandler::BlockResurrection < AbstractEffect
  def effect_flags
    EffectFlag::BLOCK_RESURRECTION.mask
  end
end
