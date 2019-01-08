class EffectHandler::TakeFort < AbstractEffect
  def instant?
    true
  end

  def on_start(info)
    return unless info.effector.player?

    if fort = FortManager.get_fort(info.effector.acting_player)
      fort.end_of_siege(info.effector.acting_player.clan)
    end
  end
end
