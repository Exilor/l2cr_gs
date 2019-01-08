class EffectHandler::Detection < AbstractEffect
  def instant?
    true
  end

  def on_start(info)
    return if !info.effector.player? || !info.effected.player?

    player = info.effector.acting_player
    target = info.effected.acting_player

    if target.invisible?
      return if player.in_party_with?(target)
      return if player.in_clan_with?(target)
      return if player.in_ally_with?(target)
    end

    target.effect_list.stop_skill_effects(true, AbnormalType::HIDE)
  end
end
