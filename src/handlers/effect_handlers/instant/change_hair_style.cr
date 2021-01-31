class EffectHandler::ChangeHairStyle < AbstractEffect
  @value : Int8

  def initialize(attach_cond, apply_cond, set, params)
    super
    @value = params.get_i8("value", 0)
  end

  def instant? : Bool
    true
  end

  def on_start(info : BuffInfo)
    effector, effected = info.effector, info.effected
    return unless effector.is_a?(L2PcInstance) && effected.is_a?(L2PcInstance)
    return if effected.looks_dead?

    effected.appearance.hair_style = @value
    effected.broadcast_user_info
  end
end
