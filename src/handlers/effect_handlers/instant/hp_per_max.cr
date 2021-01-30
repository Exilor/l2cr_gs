class EffectHandler::HpPerMax < AbstractEffect
  @power : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super
    @power = params.get_i32("power", 0)
  end

  def effect_type : EffectType
    EffectType::HP
  end

  def instant? : Bool
    true
  end

  def on_start(info)
    target = info.effected
    return if target.dead? || target.door?
    power = @power
    full = power == 100

    amount = full ? target.max_hp : (target.max_hp * power) // 100
    amount = Math.max(Math.min(amount, target.max_recoverable_hp - target.current_hp), 0)

    if amount != 0
      target.current_hp += amount
    end

    return unless target.acting_player # custom

    if info.effector != target
      sm = SystemMessage.s2_hp_has_been_restored_by_c1
      sm.add_char_name(info.effector)
    else
      sm = SystemMessage.s1_hp_has_been_restored
    end

    sm.add_int(amount)
    target.send_packet(sm)
  end
end
