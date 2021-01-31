class EffectHandler::ImmobileBuff < AbstractEffect
  def effect_type : EffectType
    EffectType::BUFF
  end

  def on_start(info : BuffInfo)
    info.effected.immobilized = true
  end

  def on_exit(info : BuffInfo)
    info.effected.immobilized = false
  end
end
