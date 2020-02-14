class EffectHandler::HpDrain < AbstractEffect
  @power : Float64
  @drain : Float64

  def initialize(attach_cond, apply_cond, set, params)
    super

    @power = params.get_f64("power", 0)
    @drain = params.get_f64("drain", 0)
  end

  def instant? : Bool
    true
  end

  def effect_type : EffectType
    EffectType::HP_DRAIN
  end

  def on_start(info)
    target, char, skill = info.effected, info.effector, info.skill

    return if char.looks_dead?

    sps = skill.use_spiritshot? && char.charged_shot?(ShotType::SPIRITSHOTS)
    bss = skill.use_spiritshot? && char.charged_shot?(ShotType::BLESSED_SPIRITSHOTS)
    mcrit = Formulas.m_crit(char.get_m_critical_hit(target, skill).to_f)
    shld = Formulas.shld_use(char, target, skill)
    damage = Formulas.magic_dam(char, target, skill, shld, sps, bss, mcrit, @power)

    cp = target.current_cp
    hp = target.current_hp

    if cp > 0
      drain = damage < cp ? 0.0 : damage - cp
    elsif damage > hp
      drain = hp
    else
      drain = damage
    end

    hp_add = @drain * drain
    if char.current_hp + hp_add > char.max_hp
      hp_final = char.max_hp.to_f
    else
      hp_final = char.current_hp + hp_add
    end

    char.current_hp = hp_final

    if damage > 0
      if Formulas.atk_break(target, damage)
        target.break_attack
        target.break_cast
      end

      char.send_damage_message(target, damage.to_i, mcrit, false, false)
      target.reduce_current_hp(damage, char, skill)
      target.notify_damage_received(damage, char, skill, mcrit, false, false)
    end
  end
end
