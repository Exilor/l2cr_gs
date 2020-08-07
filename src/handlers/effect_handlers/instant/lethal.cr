class EffectHandler::Lethal < AbstractEffect
  @full_lethal : Float64
  @half_lethal : Float64

  def initialize(attach_cond, apply_cond, set, params)
    super

    @full_lethal = params.get_f64("fullLethal", 0)
    @half_lethal = params.get_f64("halfLethal", 0)
  end

  def instant? : Bool
    true
  end

  def on_start(info)
    target = info.effected
    char = info.effector
    skill = info.skill

    if char.player? && !char.access_level.can_give_damage?
      return
    end

    if skill.magic_level < target.level &- 6
      return
    end

    if !target.lethalable? || target.invul?
      return
    end

    chance_multiplier = Formulas.attribute_bonus(char, target, skill)
    chance_multiplier *= Formulas.general_trait_bonus(char, target, skill.trait_type, false)

    if Rnd.rand(100) < @full_lethal * chance_multiplier
      if target.player?
        target.notify_damage_received(target.current_hp - 1, char, skill, true, false, false)
        target.current_cp = 1
        target.current_hp = 1
        target.send_packet(SystemMessageId::LETHAL_STRIKE)
      elsif target.monster? || target.summon?
        target.notify_damage_received(target.current_hp - 1, char, skill, true, false, false)
        target.current_hp = 1
      end

      char.send_packet(SystemMessageId::LETHAL_STRIKE_SUCCESSFUL)
    elsif Rnd.rand(100) < @half_lethal * chance_multiplier
      if target.player?
        target.current_cp = 1
        target.send_packet(SystemMessageId::HALF_KILL)
        target.send_packet(SystemMessageId::CP_DISAPPEARS_WHEN_HIT_WITH_A_HALF_KILL_SKILL)
      elsif target.monster? || target.summon?
        target.notify_damage_received(target.current_hp / 2, char, skill, true, false, false)
        target.current_hp /= 2
      end

      char.send_packet(SystemMessageId::HALF_KILL)
    end
  end
end
