class EffectHandler::Transformation < AbstractEffect
  @id : Int32

  def initialize(attach_cond : Condition?, apply_cond : Condition?, set : StatsSet, params : StatsSet)
    super
    @id = params.get_i32("id", 0)
  end

  def can_start?(info : BuffInfo) : Bool
    info.effected.player?
  end

  def on_start(info : BuffInfo)
    TransformData.transform_player(@id, info.effected.acting_player.not_nil!)
  end

  def on_exit(info : BuffInfo)
    info.effected.stop_transformation(false)
  end
end
