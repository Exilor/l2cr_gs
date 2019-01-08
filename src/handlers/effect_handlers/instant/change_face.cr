class EffectHandler::ChangeFace < AbstractEffect
  @value : Int8

  def initialize(attach_cond, apply_cond, set, params)
    super
    @value = params.get_i8("value", 0)
  end

  def instant?
    true
  end

  def on_start(info)
    return unless pc = info.effector.acting_player?
    return if pc.looks_dead?
    pc.appearance.face = @value
    pc.broadcast_user_info
  end
end
