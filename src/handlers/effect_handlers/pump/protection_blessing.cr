class EffectHandler::ProtectionBlessing < AbstractEffect
  def effect_flags : UInt32
    EffectFlag::PROTECTION_BLESSING.mask
  end

  def can_start?(info : BuffInfo) : Bool
    info.effected.player?
  end
end
