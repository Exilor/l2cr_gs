module EffectHandler
  class Heal < AbstractEffect
    @power : Float64

    def initialize(attach_cond, apply_cond, set, params)
      super
      @power = params.get_f64("power", 0)
    end

    def effect_type : EffectType
      EffectType::HP
    end

    def on_start(info)
      char, target = info.effector, info.effected
      skill = info.skill

      return if target.dead? || target.door? || target.invul?

      amount = @power
      static_shot_bonus = 0.0
      m_atk_mul = 1
      sps = skill.use_spiritshot? && char.charged_shot?(ShotType::SPIRITSHOTS)
      bss = skill.use_spiritshot? && char.charged_shot?(ShotType::BLESSED_SPIRITSHOTS)

      if ((sps || bss) && (char.is_a?(L2PcInstance) && char.mage_class?)) || char.summon?
        static_shot_bonus = skill.mp_consume2
        m_atk_mul = bss ? 4 : 2
        static_shot_bonus *= 2.4 if bss
      elsif (sps || bss) && char.npc?
        static_shot_bonus = 2.4 * skill.mp_consume2
        m_atk_mul = 4
      else
        if grade = char.active_weapon_instance.try &.template.item_grade
          m_atk_mul = grade.s84? ? 4 : grade.s80? ? 2 : 1
        end
        m_atk_mul = bss ? m_atk_mul * 4 : m_atk_mul + 1
      end

      unless skill.static?
        amount += static_shot_bonus
        amount += Math.sqrt(m_atk_mul * char.get_m_atk(char, nil))
        amount = char.calc_stat(Stats::HEAL_EFFECT, amount)
        if skill.magic?
          if Formulas.m_crit(char.get_m_critical_hit(target, skill).to_f)
            amount *= 3
          end
        end
      end

      amount = Math.max(Math.min(amount, target.max_recoverable_hp - target.current_hp), 0)

      if amount != 0
        target.current_hp += amount
      end

      if target.player?
        if skill.id == 4051
          target.send_packet(SystemMessageId::REJUVENATING_HP)
        else
          if char.player? && char != target
            sm = SystemMessage.s2_hp_has_been_restored_by_c1
            sm.add_string(char.name)
            sm.add_int(amount)
            target.send_packet(sm)
          else
            sm = SystemMessage.s1_hp_has_been_restored
            sm.add_int(amount)
            target.send_packet(sm)
          end
        end
      end
    end

    def instant? : Bool
      true
    end
  end
end
