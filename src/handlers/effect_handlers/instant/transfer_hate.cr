class EffectHandler::TransferHate < AbstractEffect
  @chance : Float64

  def initialize(attach_cond : Condition?, apply_cond : Condition?, set : StatsSet, params : StatsSet)
    super
    @chance = params.get_f64("chance", 100)
  end

  def calc_success(info : BuffInfo) : Bool
    Formulas.probability(@chance, info.effector, info.effected, info.skill)
  end

  def instant? : Bool
    true
  end

  def on_start(info : BuffInfo)
    skill, effector, effected = info.skill, info.effector, info.effected

    unless Util.in_range?(skill.effect_range, effector, effected, true)
      return
    end

    effector.known_list.get_known_characters_in_radius(skill.affect_range) do |hater|
      next unless hater.is_a?(L2Attackable) && hater.alive?

      hate = hater.get_hating(effector)
      next if hate <= 0

      hater.reduce_hate(effector, -hate)
      hater.add_damage_hate(effected, 0, hate)
    end
  end
end
