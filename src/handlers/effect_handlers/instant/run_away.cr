class EffectHandler::RunAway < AbstractEffect
  @power : Int32
  @time : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super

    @power = params.get_i32("power", 0)
    @time = params.get_i32("time", 0)
  end

  def instant?
    true
  end

  def on_start(info)
    return unless target = info.effected.as?(L2Attackable)
    return if Rnd.rand(100) > @power

    if target.casting_now? && target.can_abort_cast?
      target.abort_cast
    end
    target.ai.fear_time = @time
    target.notify_event(AI::AFRAID, info.effector, true)
  end
end
