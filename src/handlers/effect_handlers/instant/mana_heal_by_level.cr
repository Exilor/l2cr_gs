class EffectHandler::ManaHealByLevel < AbstractEffect
  @power : Float64

  def initialize(attach_cond : Condition?, apply_cond : Condition?, set : StatsSet, params : StatsSet)
    super
    @power = params.get_f64("power", 0)
  end

  def effect_type : EffectType
    EffectType::MANAHEAL_BY_LEVEL
  end

  def instant? : Bool
    true
  end

  def on_start(info : BuffInfo)
    target = info.effected
    if target.dead? || target.door? || target.invul? || target.mp_blocked?
      return
    end
    amount = target.calc_stat(Stats::MANA_CHARGE, @power)

    if target.level > info.skill.magic_level
      lvl_diff = target.level &- info.skill.magic_level
      case
      when lvl_diff == 6
        amount *= 0.9
      when lvl_diff == 7
        amount *= 0.8
      when lvl_diff == 8
        amount *= 0.7
      when lvl_diff == 9
        amount *= 0.6
      when lvl_diff == 10
        amount *= 0.5
      when lvl_diff == 11
        amount *= 0.4
      when lvl_diff == 12
        amount *= 0.3
      when lvl_diff == 13
        amount *= 0.2
      when lvl_diff == 14
        amount *= 0.1
      when lvl_diff >= 15
        amount = 0
      end
    end

    amount = Math.max(Math.min(amount, target.max_recoverable_mp - target.current_mp), 0)

    if amount != 0
      target.current_mp += amount
    end

    if target.acting_player # custom
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
