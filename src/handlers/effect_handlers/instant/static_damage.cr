class EffectHandler::StaticDamage < AbstractEffect
  @power : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super
    @power = params.get_i32("power", 0)
  end

  def on_start(info)
    char = info.effector
    return if char.looks_dead?
    target = info.effected

    target.reduce_current_hp(@power.to_f64, char, info.skill)
    target.notify_damage_received(@power, char, info.skill, false, false, false)

    if char.player?
      char.send_damage_message(target, @power, false, false, false)
    end
  end

  def instant?
    true
  end
end
