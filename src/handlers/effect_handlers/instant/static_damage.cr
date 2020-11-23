class EffectHandler::StaticDamage < AbstractEffect
  @power : Float64

  def initialize(attach_cond, apply_cond, set, params)
    super
    @power = params.get_f64("power", 0)
  end

  def on_start(info)
    char = info.effector
    return if char.looks_dead?
    target = info.effected

    target.reduce_current_hp(@power, char, info.skill)
    target.notify_damage_received(@power, char, info.skill, false, false, false)

    if char.player?
      char.send_damage_message(target, @power.to_i32, false, false, false)
    end
  end

  def instant? : Bool
    true
  end
end
