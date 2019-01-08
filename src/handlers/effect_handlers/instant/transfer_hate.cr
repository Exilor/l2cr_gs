class EffectHandler::TransferHate < AbstractEffect
  @chance : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super
    @chance = params.get_i32("chance", 100)
  end

  def calc_success(info)
    Formulas.probability(@chance.to_f, info.effector, info.effected, info.skill)
  end

  def instant?
    true
  end

  def on_start(info)
    skill, effector, effected = info.skill, info.effector, info.effected

    unless Util.in_range?(skill.effect_range, effector, effected, true)
      debug "#{effector.name} not in affect range (#{skill.effect_range}) of #{effected.name}."
      return
    end

    effector.known_list.each_character(skill.affect_range) do |obj|
      next unless obj.is_a?(L2Attackable) && obj.alive?

      hate = obj.get_hating(effector)
      next if hate <= 0

      obj.reduce_hate(effector, -hate)
      obj.add_damage_hate(effected, 0, hate)
    end
  end
end
