class EffectHandler::FatalBlow < AbstractEffect
  @power : Float64
  @blow_chance : Int32
  @critical_chance : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super

    @power = params.get_f64("power", 0)
    @blow_chance = params.get_i32("blowChance", 0)
    @critical_chance = params.get_i32("criticalChance", 0)
  end

  def calc_success(info : BuffInfo) : Bool
    !Formulas.physical_skill_evasion(info.effector, info.effected, info.skill) &&
    Formulas.blow_success(info.effector, info.effected, info.skill, @blow_chance)
  end

  def effect_type : EffectType
    EffectType::PHYSICAL_ATTACK
  end

  def instant? : Bool
    true
  end

  def on_start(info)
    char, target, skill = info.effector, info.effected, info.skill
    return if char.looks_dead?

    ss = skill.use_soulshot? && char.charged_shot?(ShotType::SOULSHOTS)
    shld = Formulas.shld_use(char, target, skill)
    damage = Formulas.blow_damage(char, target, skill, shld, ss, @power)
    if skill.max_soul_consume_count > 0
      charged_souls = info.charges
      damage *= 1 + (charged_souls * 0.04)
    end

    crit = false

    if @critical_chance > 0
      crit = Formulas.skill_crit(char, target, @critical_chance)
    end

    if crit
      damage *= 2
    end

    target.reduce_current_hp(damage, char, skill)
    target.notify_damage_received(damage, char, skill, crit, false, false)

    if Formulas.atk_break(target, damage)
      target.break_attack
      target.break_cast
    end

    if pc = char.as?(L2PcInstance)
      pc.send_damage_message(char, damage.to_i, false, crit, false)
    end

    Formulas.damage_reflected(char, target, skill, crit)
  end
end
