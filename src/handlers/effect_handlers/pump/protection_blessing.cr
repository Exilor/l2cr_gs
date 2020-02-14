class EffectHandler::ProtectionBlessing < AbstractEffect
  def effect_flags
    EffectFlag::PROTECTION_BLESSING.mask
  end

  def can_start?(info : BuffInfo) : Bool
    info.effected.player?
  end
end
