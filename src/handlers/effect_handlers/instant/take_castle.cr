class EffectHandler::TakeCastle < AbstractEffect
  def instant?
    true
  end

  def on_start(info)
    return unless info.effector.player?
    castle = CastleManager.get_castle!(info.effector.acting_player)
    castle.engrave(info.effector.acting_player.clan, info.effected)
  end
end
