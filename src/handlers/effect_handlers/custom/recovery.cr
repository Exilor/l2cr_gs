class EffectHandler::Recovery < AbstractEffect
  def instant?
    true
  end

  def on_start(info)
    if info.effected.player?
      info.effected.acting_player.reduce_death_penalty_buff_level
    end
  end
end
