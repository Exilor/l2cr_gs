# class EffectHandler::SoulBlow < AbstractEffect
#   @power : Float64
#   @blow_chance : Int32

#   def initialize(attach_cond, apply_cond, set, params)
#     super

#     @power = params.get_f64("power", 0)
#     @blow_chance = params.get_i32("blowChance", 0)
#   end

#   def calc_success(info : BuffInfo) : Bool
#     a = Formulas.physical_skill_evasion(info.effector, info.effected, info.skill)
#     b = Formulas.blow_success(info.effector, info.effected, info.skill, @blow_chance)
#     !a && b
#   end

#   def effect_type : EffectType
#     EffectType::PHYSICAL_ATTACK
#   end

#   def instant? : Bool
#     true
#   end

#   def on_start(info)
#     char, target, skill = info.effector, info.effected, info.skill
#     return if char.looks_dead?

#     ss = skill.use_soulshot? && char.charged_shot?(ShotType::SOULSHOTS)
#     shld = Formulas.shld_use(char, target, skill)
#     damage = Formulas.blow_damage(char, target, skill, shld, ss, @power)
#     if info.skill.max_soul_consume_count > 0 && char.player?
#       charged_souls = info.charges
#       damage *= 1.0 + (charged_souls * 0.04)
#     end

#     target.reduce_current_hp(damage, char, skill)
#     target.notify_damage_received(damage, char, skill, false, false, false)

#     if !target.raid? && Formulas.atk_break(target, damage)
#       target.break_attack
#       target.break_cast
#     end

#     if char.is_a?(L2PcInstance)
#       char.send_damage_message(target, damage.to_i, false, true, false)
#     end

#     Formulas.damage_reflected(char, target, skill, true)
#   end
# end

class EffectHandler::SoulBlow < EffectHandler::FatalBlow
  # Handling of damage boost using souls has been moved to FatalBlow.
end
