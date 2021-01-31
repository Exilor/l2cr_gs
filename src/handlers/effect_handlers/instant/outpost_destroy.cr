class EffectHandler::OutpostDestroy < AbstractEffect
  include Loggable

  def instant? : Bool
    true
  end

  def on_start(info : BuffInfo)
    return unless pc = info.effector.acting_player
    return unless clan = pc.clan
    return unless pc.clan_leader?

    unless TerritoryWarManager.tw_in_progress?
      return
    end

    if flag = TerritoryWarManager.get_hq_for_clan(clan)
      flag.delete_me
    else
      warn { "Flag for clan #{clan} not found." }
    end

    TerritoryWarManager.set_hq_for_clan(clan, nil)
  end
end
