require "../../../enums/effect_calculation_type"

module EffectHandler
  class Hp < AbstractEffect
    @amount : Float64
    @mode : EffectCalculationType

    def initialize(attach_cond, apply_cond, set, params)
      super

      @amount = params.get_f64("amount", 0)
      @mode = params.get_enum("mode", EffectCalculationType, EffectCalculationType::DIFF)
    end

    def effect_type
      L2EffectType::HP
    end

    def instant?
      true
    end

    def on_start(info)
      target = info.effected

      if target.dead? || target.door? || target.invul? || target.hp_blocked?
        return
      end

      char = info.effector

      amount = 0.0

      case @mode
      when .diff?
        amount = Math.min(@amount, target.max_recoverable_hp - target.current_hp)
      else
        if @amount < 0
          amount = (target.current_hp * @amount) / 100
        else
          amount = (target.max_hp * @amount) / 100
          amount = Math.max(amount, target.max_recoverable_hp - target.current_hp)
        end
      end

      if amount != 0
        target.current_hp += amount
      end

      if amount >= 0
        if char && char != target
          sm = SystemMessage.s2_hp_has_been_restored_by_c1
          sm.add_char_name(char)
        else
          sm = SystemMessage.s1_hp_has_been_restored
        end
        sm.add_int(amount)
        target.send_packet(sm)
      end
    end
  end
end
