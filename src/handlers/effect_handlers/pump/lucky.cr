class EffectHandler::Lucky < AbstractEffect
  def can_start?(info : BuffInfo) : Bool
    info.effected.is_a?(L2PcInstance)
  end

  def on_action_time(info : BuffInfo) : Bool
    info.skill.passive?
  end
end
