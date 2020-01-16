class EffectHandler::RefuelAirship < AbstractEffect
  @value : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super
    @value = params.get_i32("value", 0)
  end

  def effect_type : EffectType
    EffectType::REFUEL_AIRSHIP
  end

  def on_start(info)
    return unless ship = info.effector.acting_player.try &.airship
    ship.fuel += @value
    ship.update_abnormal_effect
  end

  def instant? : Bool
    false
  end
end
