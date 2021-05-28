class EffectHandler::MpPerMax < AbstractEffect
  @power : Float64

  def initialize(attach_cond : Condition?, apply_cond : Condition?, set : StatsSet, params : StatsSet)
    super
    @power = params.get_f64("power", 0)
  end

  def effect_type : EffectType
    EffectType::MANAHEAL_PERCENT
  end

  def instant? : Bool
    true
  end

  def on_start(info : BuffInfo)
    target = info.effected
    return if target.dead? || target.door?

    power = @power
    full = power == 100
    amount = full ? target.max_mp.to_f : (target.max_mp * power) / 100.0

    if amount != 0
      target.current_mp += amount
    end

    return unless target.acting_player # custom

    if info.effector != target
      sm = SystemMessage.s2_mp_has_been_restored_by_c1
      sm.add_char_name(info.effector)
    else
      sm = SystemMessage.s1_mp_has_been_restored
    end

    sm.add_int(amount)
    target.send_packet(sm)
  end
end
