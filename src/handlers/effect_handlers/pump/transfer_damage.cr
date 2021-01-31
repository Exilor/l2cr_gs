class EffectHandler::TransferDamage < AbstractEffect
  def on_start(info : BuffInfo)
    effector, effected = info.effector, info.effected

    if effected.is_a?(L2Playable) && effector.is_a?(L2PcInstance)
      effected.transferring_damage_to = effector.acting_player
    end
  end

  def on_exit(info : BuffInfo)
    effector, effected = info.effector, info.effected

    if effected.is_a?(L2Playable) && effector.is_a?(L2PcInstance)
      effected.transferring_damage_to = nil
    end
  end
end
