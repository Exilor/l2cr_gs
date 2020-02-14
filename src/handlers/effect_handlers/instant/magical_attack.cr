class EffectHandler::MagicalAttack < AbstractEffect
  @power : Float64

  def initialize(attach_cond, apply_cond, set, params)
    super
    @power = params.get_f64("power", 0)
  end

  def instant? : Bool
    true
  end

  def effect_type : EffectType
      EffectType::MAGICAL_ATTACK
    end

  def on_start(info)
    target, char, skill = info.effected, info.effector, info.skill

    if char.looks_dead?
      return
    end

    if target.is_a?(L2PcInstance) && target.fake_death?
      target.stop_fake_death(true)
    end

    sps = skill.use_spiritshot? && char.charged_shot?(ShotType::SPIRITSHOTS)
    bss = skill.use_spiritshot? && char.charged_shot?(ShotType::BLESSED_SPIRITSHOTS)
    mcrit = Formulas.m_crit(char.get_m_critical_hit(target, skill).to_f)
    shld = Formulas.shld_use(char, target, skill)
    damage = Formulas.magic_dam(char, target, skill, shld, sps, bss, mcrit, @power)

    if skill.max_soul_consume_count > 0
      charged_souls = info.charges
      damage *= 1 + (charged_souls * 0.04)
    end

    if damage > 0
      if Formulas.atk_break(target, damage)
        target.break_attack
        target.break_cast
      end

      if target.calc_stat(Stats::VENGEANCE_SKILL_MAGIC_DAMAGE, 0, target, skill) > Rnd.rand(100)
        char.reduce_current_hp(damage, target, skill)
        char.notify_damage_received(damage, target, skill, mcrit, false, true)
      else
        target.reduce_current_hp(damage, char, skill)
        target.notify_damage_received(damage, char, skill, mcrit, false, false)
        char.send_damage_message(target, damage.to_i, mcrit, false, false)
      end
    end
  end
end
