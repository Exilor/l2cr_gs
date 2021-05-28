class EffectHandler::DeleteHate < AbstractEffect
  @chance : Float64

  def initialize(attach_cond : Condition?, apply_cond : Condition?, set : StatsSet, params : StatsSet)
    super
    @chance = params.get_f64("chance", 100)
  end

  def calc_success(info : BuffInfo) : Bool
    Formulas.probability(@chance, info.effector, info.effected, info.skill)
  end

  def effect_type : EffectType
    EffectType::HATE
  end

  def instant? : Bool
    true
  end

  def on_start(info : BuffInfo)
    target = info.effected
    return unless target.is_a?(L2Attackable)
    target.clear_aggro_list
    target.set_walking
    target.intention = AI::ACTIVE
  end
end
