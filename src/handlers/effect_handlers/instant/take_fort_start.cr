class EffectHandler::TakeFortStart < AbstractEffect
  def instant? : Bool
    true
  end

  def on_start(info)
    return unless info.effector.player?
    return unless pc = info.effector.acting_player
    return unless fort = FortManager.get_fort(pc)
    return unless clan = pc.clan
    fort.siege.announce_to_player(SystemMessage.s1_trying_raise_flag, clan.name)
  end
end
