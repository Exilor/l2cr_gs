class EffectHandler::PhysicalAttackHpLink < AbstractEffect
  @power : Float64

  def initialize(attach_cond, apply_cond, set, params)
    super
    @power = params.get_f64("power", 0)
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

  def on_start(info : BuffInfo)
    target, char, skill = info.effected, info.effector, info.skill
    return if char.looks_dead?

    if char.movement_disabled?
      sm = SystemMessage.s1_cannot_be_used
      sm.add_skill_name(skill)
      char.send_packet(sm)
      return
    end

    shld = Formulas.shld_use(char, target, skill)
    ss = skill.physical? && char.charged_shot?(ShotType::SOULSHOTS)
    power = @power * (-((target.current_hp * 2) / target.max_hp) + 2)
    damage = Formulas.skill_phys_dam(char, target, skill, shld, false, ss, power)

    if damage > 0
      char.send_damage_message(target, damage.to_i, false, false, false)
      target.reduce_current_hp(damage, char, skill)
      target.notify_damage_received(damage, char, skill, false, false, false)

      Formulas.damage_reflected(char, target, skill, false)
    else
      char.send_packet(SystemMessageId::ATTACK_FAILED)
    end
  end
end
