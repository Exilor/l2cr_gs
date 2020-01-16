class EffectHandler::GetAgro < AbstractEffect
  def effect_type : EffectType
    EffectType::AGGRESSION
  end

  def instant? : Bool
    true
  end

  def on_start(info)
    if mob = info.effected.as?(L2Attackable)
      if mob.ai? && mob.most_hated != info.effector
        mob.set_intention(AI::ATTACK, info.effector)
      end
    end
  end
end
