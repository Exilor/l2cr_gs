class EffectHandler::InstantBetray < AbstractEffect
  @chance : Float64
  @time : Int32

  def initialize(attach_cond : Condition?, apply_cond : Condition?, set : StatsSet, params : StatsSet)
    super

    @chance = params.get_f64("chance", 0)
    @time = params.get_i32("time", 0)
  end

  def instant? : Bool
    true
  end

  def effect_flags : UInt64
    EffectFlag::BETRAYED.mask
  end

  def effect_type : EffectType
    EffectType::DEBUFF
  end

  def on_start(info : BuffInfo)
    effected = info.effected
    return if effected.raid?
    if effected.summon?
      target = effected.acting_player
    elsif effected.raid_minion? && effected.is_a?(L2Attackable)
      target = effected.leader
    end

    return unless target

    unless Formulas.probability(@chance, info.effector, effected, info.skill)
      return
    end

    ai = effected.ai
    ai.set_intention(AI::ATTACK, target)
    task = -> { ai.set_intention(AI::ATTACK, target) }
    ThreadPoolManager.schedule_ai_at_fixed_rate(task, 0, @time * 1000)
  end
end
