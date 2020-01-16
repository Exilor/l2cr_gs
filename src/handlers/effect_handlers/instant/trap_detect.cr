class EffectHandler::TrapDetect < AbstractEffect
  @power : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super

    if params.empty?
      raise ArgumentError.new("effect without power")
    end

    @power = params.get_i32("power")
  end

  def instant? : Bool
    true
  end

  def on_start(info)
    trap = info.effected
    return unless trap.is_a?(L2TrapInstance)
    return if trap.looks_dead?

    if trap.level <= @power
      trap.set_detected(info.effector)
    end
  end
end
