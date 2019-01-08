class EffectHandler::MpPerMax < AbstractEffect
  @power : Float64

  def initialize(attach_cond, apply_cond, set, params)
    super
    @power = params.get_f64("power", 0)
  end

  def effect_type
    L2EffectType::MANAHEAL_PERCENT
  end

  def instant?
    true
  end

  def on_start(info)
    target = info.effected
    return if target.dead? || target.door?

    amount = 0.0
    power = @power
    full = power == 100
    amount = full ? target.max_mp.to_f : (target.max_mp * power) / 100.0

    if amount != 0
      target.current_mp += amount
    end

    if target.acting_player? # custom
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
end
