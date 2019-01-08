class EffectHandler::GetAgro < AbstractEffect
  def effect_type
    L2EffectType::AGGRESSION
  end

  def instant?
    true
  end

  def on_start(info)
    if mob = info.effected.as?(L2Attackable)
      mob.set_intention(AI::ATTACK, info.effector)
    end
  end
end
