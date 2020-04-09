class EffectHandler::Cp < AbstractEffect
  @amount : Float64
  @mode : EffectCalculationType

  def initialize(attach_cond, apply_cond, set, params)
    super

    @amount = params.get_f64("amount", 0)
    @mode = params.get_enum("mode", EffectCalculationType, EffectCalculationType::DIFF)
  end

  def effect_type : EffectType
    EffectType::CP
  end

  def instant? : Bool
    true
  end

  def on_start(info)
    target = info.effected
    return if target.dead? || !target.player?
    char = info.effector

    amount = 0.0

    case @mode
    when EffectCalculationType::DIFF
      amount = @amount.clamp(0, target.max_recoverable_cp - target.current_cp)
    when EffectCalculationType::PER
      if @amount < 0
        amount = (target.current_cp * @amount) / 100
      else
        amount = Math.max((target.max_cp * @amount) / 100.0, target.max_recoverable_cp - target.current_cp)
      end
    else
      # [automatically added else]
    end


    if amount != 0
      target.current_cp += amount
    end

    if amount >= 0
      if char && char != target
        sm = SystemMessage.s2_cp_has_been_restored_by_c1
        sm.add_char_name(char)
      else
        sm = SystemMessage.s1_cp_has_been_restored
      end
      sm.add_int(amount)
      target.send_packet(sm)
    end
  end
end
