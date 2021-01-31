class EffectHandler::RandomizeHate < AbstractEffect
  @chance : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super
    @chance = params.get_i32("chance", 100)
  end

  def calc_success(info : BuffInfo) : Bool
    Formulas.probability(@chance.to_f, info.effector, info.effected, info.skill)
  end

  def on_start(info : BuffInfo)
    effected, effector = info.effected, info.effector

    return unless effected.is_a?(L2Attackable)

    return if effector == effected

    aggro_list = effected.aggro_list.keys
    aggro_list.delete(effector)
    return if aggro_list.empty?

    target = aggro_list.sample(random: Rnd)
    hate = effected.get_hating(effector)
    effected.stop_hating(effector)
    effected.add_damage_hate(target, 0, hate)
  end

  def instant? : Bool
    true
  end
end
