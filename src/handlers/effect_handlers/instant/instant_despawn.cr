class EffectHandler::InstantDespawn < AbstractEffect
  @chance : Int32

  def initialize(attach_cond : Condition?, apply_cond : Condition?, set : StatsSet, params : StatsSet)
    super
    @chance = params.get_i32("chance", 0)
  end

  def instant? : Bool
    true
  end

  def on_start(info : BuffInfo)
    return unless pc = info.effected.acting_player
    return unless summon = pc.summon
    return if Rnd.rand(100) < @chance

    summon.unsummon(pc)
  end

  def effect_type : EffectType
    EffectType::BUFF
  end
end
