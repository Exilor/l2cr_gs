class EffectHandler::ImmobileBuff < AbstractEffect
  def effect_type : EffectType
    EffectType::BUFF
  end

  def on_start(info)
    info.effected.immobilized = true
  end

  def on_exit(info)
    info.effected.immobilized = false
  end
end
