class EffectHandler::DeleteHateOfMe < AbstractEffect
  @chance : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super
    @chance = params.get_i32("chance", 100)
  end

  def calc_success(info)
    Formulas.probability(@chance.to_f, info.effector, info.effected, info.skill)
  end

  def effect_type
    L2EffectType::HATE
  end

  def instant?
    true
  end

  def on_start(info)
    target = info.effected
    return unless target.is_a?(L2Attackable)
    target.stop_hating(info.effector)
    target.set_walking
    target.intention = AI::ACTIVE
  end
end
