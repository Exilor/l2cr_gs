class EffectHandler::PhysicalAttack < AbstractEffect
  @power : Float64
  @critical_chance : Int32
  @ignore_shield_defence : Bool

  def initialize(attach_cond, apply_cond, set, params)
    super

    @power = params.get_f64("power", 0)
    @critical_chance = params.get_i32("criticalChance", 0)
    @ignore_shield_defence = params.get_bool("ignoreShieldDefence", false)
  end

  def calc_success(info : BuffInfo) : Bool
    !Formulas.physical_skill_evasion(info.effector, info.effected, info.skill)
  end

  def effect_type : EffectType
    EffectType::PHYSICAL_ATTACK
  end

  def instant? : Bool
    true
  end

  def on_start(info)
    target, char, skill = info.effected, info.effector, info.skill
    return if char.looks_dead?

    if target.is_a?(L2PcInstance) && target.fake_death?
      target.stop_fake_death(true)
    end

    ss = skill.physical? && char.charged_shot?(ShotType::SOULSHOTS)
    shld = 0i8
    unless @ignore_shield_defence
      shld = Formulas.shld_use(char, target, skill, true)
    end
    crit = false

    if @critical_chance > 0
      crit = Formulas.skill_crit(char, target, @critical_chance)
    end

    damage = Formulas.skill_phys_dam(char, target, skill, shld, false, ss, @power)
    damage *= Formulas.soul_bonus(skill, info)
    damage *= 2 if crit

    if damage > 0
      char.send_damage_message(target, damage.to_i, false, crit, false)
      target.reduce_current_hp(damage, char, skill)
      target.notify_damage_received(damage, char, skill, crit, false, false)
      Formulas.damage_reflected(char, target, skill, crit)
    else
      char.send_packet(SystemMessageId::ATTACK_FAILED)
    end
  end
end
