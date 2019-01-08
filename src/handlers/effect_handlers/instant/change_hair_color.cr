class EffectHandler::ChangeHairColor < AbstractEffect
  @value : Int8

  def initialize(attach_cond, apply_cond, set, params)
    super
    @value = params.get_i8("value", 0)
  end

  def instant?
    true
  end

  def on_start(info)
    effector, effected = info.effector?, info.effected?
    return unless effector && effected
    return unless effector.player? && effected.player?
    return if effected.looks_dead?

    pc = effected.acting_player

    pc.appearance.hair_color = @value
    pc.broadcast_user_info
  end
end
