class EffectHandler::Backstab < AbstractEffect
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
    effected, effector, skill = info.effected, info.effector, info.skill
    !info.effected.in_front_of?(effected) &&
    !Formulas.physical_skill_evasion(effector, effected, skill) &&
    Formulas.blow_success(effector, effected, skill, @blow_chance)
  end

  def effect_type : EffectType
    EffectType::PHYSICAL_ATTACK
  end

  def on_start(info)
    char = info.effector
    return if char.looks_dead?
    target = info.effected
    skill = info.skill
    ss = skill.use_soulshot? && char.charged_shot?(ShotType::SOULSHOTS)
    shld = Formulas.shld_use(char, target, skill)
    damage = Formulas.backstab_damage(char, target, skill, shld, ss, @power)

    if Formulas.skill_crit(char, target, @critical_chance)
      damage *= 2
    end

    target.reduce_current_hp(damage, char, skill)
    target.notify_damage_received(damage, char, skill, true, false, false)

    if Formulas.atk_break(target, damage)
      target.break_attack
      target.break_cast
    end

    if char.player?
      char.send_damage_message(target, damage.to_i, false, true, false)
    end

    Formulas.damage_reflected(char, target, skill, true)
  end

  def instant? : Bool
    true
  end
end
