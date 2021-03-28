class EffectHandler::Stun < AbstractEffect
  def effect_flags : UInt32
    EffectFlag::STUNNED.mask
  end

  def effect_type : EffectType
    EffectType::STUN
  end

  def on_exit(info : BuffInfo)
    info.effected.stop_stunning(false)
  end

  def on_start(info : BuffInfo)
    info.effected.start_stunning
  end
end
