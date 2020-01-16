class EffectHandler::TargetCancel < AbstractEffect
  @chance : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super
    @chance = params.get_i32("chance", 100)
  end

  def calc_success(info)
    Formulas.probability(@chance.to_f, info.effector, info.effected, info.skill)
  end

  def instant? : Bool
    true
  end

  def on_start(info)
    info.effected.target = nil
    info.effected.abort_attack
    info.effected.abort_cast
    info.effected.intention = AI::IDLE
  end
end
