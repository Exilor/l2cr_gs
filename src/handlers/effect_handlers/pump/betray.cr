class EffectHandler::Betray < AbstractEffect
  def can_start?(info : BuffInfo) : Bool
    info.effector.player? && info.effected.summon?
  end

  def effect_flags
    EffectFlag::BETRAYED.mask
  end

  def effect_type : EffectType
    EffectType::DEBUFF
  end

  def on_start(info)
    info.effected.set_intention(AI::ATTACK, info.effected.acting_player)
  end

  def on_exit(info)
    info.effected.intention = AI::IDLE
  end
end
