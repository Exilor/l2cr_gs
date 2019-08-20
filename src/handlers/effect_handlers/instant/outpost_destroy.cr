class EffectHandler::OutpostDestroy < AbstractEffect
  def instant?
    true
  end

  def on_start(info)
    pc = info.effector.acting_player

    unless pc.clan_leader?
      return
    end

    unless TerritoryWarManager.tw_in_progress?
      return
    end

    if flag = TerritoryWarManager.get_hq_for_clan(pc.clan)
      flag.delete_me
    else
      warn { "Flag for clan #{pc.clan} not found." }
    end

    TerritoryWarManager.set_hq_for_clan(pc.clan, nil)
  end
end
