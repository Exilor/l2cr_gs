class EffectHandler::Mp < AbstractEffect
  @amount : Float64
  @mode : EffectCalculationType

  def initialize(attach_cond : Condition?, apply_cond : Condition?, set : StatsSet, params : StatsSet)
    super

    @amount = params.get_f64("amount", 0)
    @mode = params.get_enum("mode", EffectCalculationType, EffectCalculationType::DIFF)
  end

  def instant? : Bool
    true
  end

  def on_start(info : BuffInfo)
    target = info.effected

    if target.dead? || target.door? || target.invul? || target.mp_blocked?
      return
    end

    char = info.effector

    amount = 0.0

    case @mode
    when EffectCalculationType::DIFF
      if @amount < 0
        amount = @amount
      else
        skill = info.skill
        unless skill.static?
          amount = target.calc_stat(Stats::MANA_CHARGE, @amount)
        end
        amount = skill.static? ? @amount : amount
        amount = Math.min(amount, target.max_recoverable_mp - target.current_mp)
      end
    else
      if @amount < 0
        amount = (target.current_mp * @amount) / 100
      else
        amount = (target.max_mp * @amount) / 100.0
        amount = Math.min(amount, target.max_recoverable_mp - target.current_mp)
      end
    end

    if amount >= 0
      if amount != 0
        target.current_mp += amount
      end

      return unless target.acting_player

      if char && char != target
        sm = SystemMessage.s2_mp_has_been_restored_by_c1
        sm.add_char_name(char)
      else
        sm = SystemMessage.s1_mp_has_been_restored
      end

      sm.add_int(amount)
      target.send_packet(sm)
    end
  end
end
