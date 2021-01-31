class EffectHandler::ImmobilePetBuff < AbstractEffect
  def effect_type : EffectType
    EffectType::BUFF
  end

  def on_start(info : BuffInfo)
    effected, effector = info.effected, info.effector
    if effected.is_a?(L2Summon) && effector.is_a?(L2PcInstance)
      if effected.owner == effector
        effected.immobilized = true
      end
    end
  end

  def on_exit(info : BuffInfo)
    info.effected.immobilized = false
  end
end
