class EffectHandler::InstantDispelByName < AbstractEffect
  @id : Int32

  def initialize(attach_cond : Condition?, apply_cond : Condition?, set : StatsSet, params : StatsSet)
    super
    @id = params.get_i32("id")
  end

  def instant? : Bool
    true
  end

  def on_start(info : BuffInfo)
    info.effected.effect_list.stop_skill_effects(true, @id)
  end

  def effect_type : EffectType
    EffectType::DISPEL
  end
end
