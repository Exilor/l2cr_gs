class EffectHandler::DispelAll < AbstractEffect
  def effect_type : EffectType
    EffectType::DISPEL
  end

  def instant? : Bool
    true
  end

  def on_start(info)
    info.effected.stop_all_effects
  end
end
