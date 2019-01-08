class EffectHandler::Disarm < AbstractEffect
  def can_start?(info)
    info.effected.player?
  end

  def effect_flags
    EffectFlag::DISARMED.mask
  end

  def on_start(info)
    info.effected.acting_player.disarm_weapons
  end
end
