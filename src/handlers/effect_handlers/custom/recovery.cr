class EffectHandler::Recovery < AbstractEffect
  def instant? : Bool
    true
  end

  def on_start(info)
    if pc = info.effected.as?(L2PcInstance)
      pc.reduce_death_penalty_buff_level
    end
  end
end
