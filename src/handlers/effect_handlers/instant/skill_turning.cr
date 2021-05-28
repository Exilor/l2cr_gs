class EffectHandler::SkillTurning < AbstractEffect
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
    return if info.effected == info.effector || info.effected.raid?
    info.effected.break_cast
  end
end
