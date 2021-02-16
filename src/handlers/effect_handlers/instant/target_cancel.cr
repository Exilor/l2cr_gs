class EffectHandler::TargetCancel < AbstractEffect
  @chance : Float64

  def initialize(attach_cond, apply_cond, set, params)
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
    info.effected.target = nil
    info.effected.abort_attack
    info.effected.abort_cast
    info.effected.intention = AI::IDLE
  end
end
