class EffectHandler::DispelAll < AbstractEffect
  def effect_type
    L2EffectType::DISPEL
  end

  def instant?
    true
  end

  def on_start(info)
    info.effected.stop_all_effects
  end
end
