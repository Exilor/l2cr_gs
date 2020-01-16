class EffectHandler::Debuff < AbstractEffect
  def effect_type : EffectType
    EffectType::DEBUFF
  end
end
