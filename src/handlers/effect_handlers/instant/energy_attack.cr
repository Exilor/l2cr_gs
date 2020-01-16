class EffectHandler::EnergyAttack < AbstractEffect
  @power : Float64
  @critical_chance : Int32
  @ignore_shield : Bool

  def initialize(attach_cond, apply_cond, set, params)
    super

    @power = params.get_f64("power", 0)
    @critical_chance = params.get_i32("criticalChance", 0)
    @ignore_shield = params.get_bool("ignoreShieldDefence", false)
  end

  def calc_success(info)
    # L2J wants the accuracy of this verified
    !Formulas.physical_skill_evasion(info.effector, info.effected, info.skill)
  end

  def effect_type : EffectType
    EffectType::PHYSICAL_ATTACK
  end

  def on_start(info)
    return unless attacker = info.effector.as?(L2PcInstance)
    target = info.effected
    skill = info.skill

    attack = attacker.get_p_atk(target)
    defence = target.get_p_def(attacker)

    unless @ignore_shield
      case Formulas.shld_use(attacker, target, skill, true)
      when Formulas::SHIELD_DEFENSE_FAILED
        # nothing
      when Formulas::SHIELD_DEFENSE_SUCCEED
        defence -= target.shld_def
      when Formulas::SHIELD_DEFENSE_PERFECT_BLOCK
        defence = -1.0
      end
    end

    damage = 1.0
    critical = false

    if defence != -1
      damage_multiplier = Formulas.weapon_trait_bonus(attacker, target) * Formulas.attribute_bonus(attacker, target, skill) * Formulas.general_trait_bonus(attacker, target, skill.trait_type, true)
      ss = info.skill.use_soulshot? && attacker.charged_shot?(ShotType::SOULSHOTS)
      ss_boost = ss ? 2.0 : 1.0
      weapon = attacker.active_weapon_item
      if weapon && (weapon.item_type.bow? || weapon.item_type.crossbow?)
        weapon_type_boost = 70.0
      else
        weapon_type_boost = 77.0
      end
      energy_charges_boost = (((attacker.charges + skill.charge_consume) - 1) * 0.2) + 1.0
      attack += @power
      attack *= ss_boost
      attack *= energy_charges_boost
      attack *= weapon_type_boost
      damage = attack / defence
      damage *= damage_multiplier

      if target.is_a?(L2PcInstance)
        damage *= attacker.calc_stat(Stats::PVP_PHYS_SKILL_DMG)
        damage *= target.calc_stat(Stats::PVP_PHYS_SKILL_DEF)
        damage = attacker.calc_stat(Stats::PHYSICAL_SKILL_POWER, damage)
      end

      if @critical_chance > 0
        critical = Formulas.skill_crit(attacker, target, @critical_chance)
      end

      damage *= 2 if critical
    end

    if damage > 0
      attacker.send_damage_message(target, damage.to_i, false, critical, false)
      target.reduce_current_hp(damage, attacker, skill)
      target.notify_damage_received(damage, attacker, skill, critical, false, false)

      Formulas.damage_reflected(attacker, target, skill, critical)
    end
  end

  def instant? : Bool
    true
  end
end
