class EffectHandler::NoblesseBless < AbstractEffect
  def can_start?(info)
    info.effected.playable?
  end

  def effect_flags
    EffectFlag::NOBLESS_BLESSING.mask
  end

  def effect_type : EffectType
    EffectType::NOBLESSE_BLESSING
  end
end
