class EffectHandler::TakeFortStart < AbstractEffect
  def instant?
    true
  end

  def on_start(info)
    return unless info.effector.player?
    pc = info.effector.acting_player
    fort = FortManager.get_fort(pc)
    clan = pc.clan?
    if fort && clan
      fort.siege.announce_to_player(SystemMessage.s1_trying_raise_flag, clan.name)
    end
  end
end
