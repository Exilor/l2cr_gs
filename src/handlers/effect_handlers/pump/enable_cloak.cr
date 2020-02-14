class EffectHandler::EnableCloak < AbstractEffect
  def can_start?(info : BuffInfo) : Bool
    info.effector.player?
  end

  def on_start(info)
    info.effected.acting_player.not_nil!.stat.cloak_slot_status = true
  end

  def on_action_time(info : BuffInfo) : Bool
    info.skill.passive?
  end

  def on_exit(info)
    info.effected.acting_player.not_nil!.stat.cloak_slot_status = false
  end
end
