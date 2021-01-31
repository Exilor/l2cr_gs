class EffectHandler::Detection < AbstractEffect
  def instant? : Bool
    true
  end

  def on_start(info : BuffInfo)
    return unless player = info.effector.as?(L2PcInstance)
    return unless target = info.effected.as?(L2PcInstance)

    if target.invisible?
      return if player.in_party_with?(target)
      return if player.in_clan_with?(target)
      return if player.in_ally_with?(target)
    end

    target.effect_list.stop_skill_effects(true, AbnormalType::HIDE)
  end
end
