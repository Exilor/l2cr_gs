class EffectHandler::Buff < AbstractEffect
  def effect_type
    L2EffectType::BUFF
  end

  def on_action_time(info)
    info.skill.passive? || info.skill.toggle?
  end
end
