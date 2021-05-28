class EffectHandler::Betray < AbstractEffect
  def can_start?(info : BuffInfo) : Bool
    info.effector.player? && info.effected.summon?
  end

  def effect_flags : UInt64
    EffectFlag::BETRAYED.mask
  end

  def effect_type : EffectType
    EffectType::DEBUFF
  end

  def on_start(info : BuffInfo)
    info.effected.set_intention(AI::ATTACK, info.effected.acting_player)
  end

  def on_exit(info : BuffInfo)
    info.effected.intention = AI::IDLE
  end
end
