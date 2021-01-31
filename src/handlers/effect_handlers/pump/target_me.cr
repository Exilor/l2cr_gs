class EffectHandler::TargetMe < AbstractEffect
  def on_start(info : BuffInfo)
    effector, effected = info.effector, info.effected
    return unless effected.is_a?(L2Playable)

    if effected.target != info.effector
      effector = effector.acting_player
      if effector && effector.check_pvp_skill(effected, info.skill)
        effected.target = effector
      end
    end

    effected.locked_target = effector
  end

  def on_exit(info : BuffInfo)
    if playable = info.effected.as?(L2Playable)
      playable.locked_target = nil
    end
  end
end
