class EffectHandler::DeleteHate < AbstractEffect
  @chance : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super
    @chance = params.get_i32("chance", 100)
  end

  def calc_success(info : BuffInfo) : Bool
    Formulas.probability(@chance.to_f, info.effector, info.effected, info.skill)
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
