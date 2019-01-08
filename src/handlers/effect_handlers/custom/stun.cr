class EffectHandler::Stun < AbstractEffect
  def effect_flags
    EffectFlag::STUNNED.mask
  end

  def effect_type
    L2EffectType::STUN
  end

  def on_exit(info)
    info.effected.stop_stunning(false)
  end

  def on_start(info)
    info.effected.start_stunning
  end
end
