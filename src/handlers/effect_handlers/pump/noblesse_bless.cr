class EffectHandler::NoblesseBless < AbstractEffect
  def can_start?(info : BuffInfo) : Bool
    info.effected.playable?
  end

  def effect_flags : UInt32
    EffectFlag::NOBLESS_BLESSING.mask
  end

  def effect_type : EffectType
    EffectType::NOBLESSE_BLESSING
  end
end
