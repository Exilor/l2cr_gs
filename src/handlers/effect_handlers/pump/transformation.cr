class EffectHandler::Transformation < AbstractEffect
  @id : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super
    @id = params.get_i32("id", 0)
  end

  def can_start?(info : BuffInfo) : Bool
    info.effected.player?
  end

  def on_start(info)
    TransformData.transform_player(@id, info.effected.acting_player.not_nil!)
  end

  def on_exit(info)
    info.effected.stop_transformation(false)
  end
end
