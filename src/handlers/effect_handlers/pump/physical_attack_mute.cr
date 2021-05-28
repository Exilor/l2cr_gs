class EffectHandler::PhysicalAttackMute < AbstractEffect
  def effect_flags : UInt64
    EffectFlag::PHYSICAL_ATTACK_MUTED.mask
  end

  def on_start(info : BuffInfo)
    info.effected.start_physical_attack_muted
  end
end
