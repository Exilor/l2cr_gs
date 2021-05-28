class EffectHandler::ChangeFace < AbstractEffect
  @value : Int8

  def initialize(attach_cond : Condition?, apply_cond : Condition?, set : StatsSet, params : StatsSet)
    super
    @value = params.get_i8("value", 0)
  end

  def instant? : Bool
    true
  end

  def on_start(info : BuffInfo)
    return unless pc = info.effector.acting_player
    return if pc.looks_dead?
    pc.appearance.face = @value
    pc.broadcast_user_info
  end
end
