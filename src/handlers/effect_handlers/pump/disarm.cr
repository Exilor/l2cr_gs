class EffectHandler::Disarm < AbstractEffect
  def can_start?(info : BuffInfo) : Bool
    info.effected.player?
  end

  def effect_flags : UInt64
    EffectFlag::DISARMED.mask
  end

  def on_start(info : BuffInfo)
    if pc = info.effected.acting_player
      pc.disarm_weapons
    end
  end
end
