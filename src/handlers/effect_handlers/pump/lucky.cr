class EffectHandler::Lucky < AbstractEffect
  def can_start?(info)
    effector, effected = info.effector?, info.effected?
    !!effector && effected.is_a?(L2PcInstance)
  end

  def on_action_time(info)
    info.skill.passive?
  end
end
