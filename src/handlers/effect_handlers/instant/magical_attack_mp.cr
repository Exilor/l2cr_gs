class EffectHandler::MagicalAttackMp < AbstractEffect
  @power : Float64

  def initialize(attach_cond, apply_cond, set, params)
    super
    @power = params.get_f64("power", 0)
  end

  def calc_success(info)
    target = info.effected
    return false if target.invul? || target.mp_blocked?

    skill = info.skill
    char = info.effector

    unless Formulas.magic_affected(char, target, skill)
      if char.player?
        char.send_packet(SystemMessageId::ATTACK_FAILED)
      end

      if target.player?
        sm = SystemMessage.c1_resisted_c2_drain2
        sm.add_char_name(target)
        sm.add_char_name(char)
        target.send_packet(sm)
      end

      return false
    end
    true
  end

  def effect_type : EffectType
    EffectType::MAGICAL_ATTACK
  end

  def instant? : Bool
    true
  end

  def on_start(info)
    char = info.effector
    return if char.looks_dead?

    skill = info.skill
    target = info.effected

    sps = skill.use_spiritshot? && char.charged_shot?(ShotType::SPIRITSHOTS)
    bss = skill.use_spiritshot? && char.charged_shot?(ShotType::BLESSED_SPIRITSHOTS)
    mcrit = Formulas.m_crit(char.get_m_critical_hit(target, skill).to_f)
    shld = Formulas.shld_use(char, target, skill)
    damage = Formulas.mana_dam(char, target, skill, shld, sps, bss, mcrit, @power)
    mp = damage > target.current_mp ? target.current_mp : damage

    if damage > 0
      target.stop_effects_on_damage(true)
      target.current_mp -= mp
    end

    # these messages are deprecated
    if target.player?
      sm = SystemMessage.s2_mp_has_been_drained_by_c1
      sm.add_char_name(char)
      sm.add_int(mp)
      target.send_packet(sm)
    end

    if char.player?
      sm = SystemMessage.your_opponents_mp_was_reduced_by_s1
      sm.add_int(mp)
      char.send_packet(sm)
    end
  end
end
