class EffectHandler::Teleport < AbstractEffect
  def initialize(attach_cond : Condition?, apply_cond : Condition?, set : StatsSet, params : StatsSet)
    super

    x = params.get_i32("x", 0)
    y = params.get_i32("y", 0)
    z = params.get_i32("z", 0)
    @loc = Location.new(x, y, z)
  end

  def effect_type : EffectType
    EffectType::TELEPORT
  end

  def instant? : Bool
    true
  end

  def on_start(info : BuffInfo)
    info.effected.tele_to_location(@loc, true)
  end
end
