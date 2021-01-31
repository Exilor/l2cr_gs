class EffectHandler::TakeFort < AbstractEffect
  def instant? : Bool
    true
  end

  def on_start(info : BuffInfo)
    return unless pc = info.effector.as?(L2PcInstance)

    if (clan = pc.clan) && (fort = FortManager.get_fort(pc))
      fort.end_of_siege(clan)
    end
  end
end
