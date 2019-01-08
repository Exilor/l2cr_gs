class EffectHandler::PhysicalAttackMute < AbstractEffect
  def effect_flags
    EffectFlag::PHYSICAL_ATTACK_MUTED.mask
  end

  def on_start(info)
    info.effected.start_physical_attack_muted
  end
end
