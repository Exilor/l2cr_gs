class EffectHandler::TargetMeProbability < AbstractEffect
  @chance : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super
    @chance = params.get_i32("chance", 100)
  end

  def instant?
    true
  end

  def calc_success(info)
    Formulas.probability(@chance.to_f, info.effector, info.effected, info.skill)
  end

  def on_start(info)
    effector, effected = info.effector, info.effected

    return unless effected.playable?
    return if effected.target == effector
    return unless effector = effector.acting_player?

    if effector.check_pvp_skill(effected, info.skill)
      effected.target = info.effector
    end
  end
end
