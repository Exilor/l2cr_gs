class EffectHandler::TargetMeProbability < AbstractEffect
  @chance : Float64

  def initialize(attach_cond : Condition?, apply_cond : Condition?, set : StatsSet, params : StatsSet)
    super
    @chance = params.get_f64("chance", 100)
  end

  def instant? : Bool
    true
  end

  def calc_success(info : BuffInfo) : Bool
    Formulas.probability(@chance, info.effector, info.effected, info.skill)
  end

  def on_start(info : BuffInfo)
    effector, effected = info.effector, info.effected

    return unless effected.playable?
    return if effected.target == effector
    return unless effector = effector.acting_player

    if effector.check_pvp_skill(effected, info.skill)
      effected.target = info.effector
    end
  end
end
