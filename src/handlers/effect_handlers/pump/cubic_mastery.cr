class EffectHandler::CubicMastery < AbstractEffect
  @cubic_count : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super
    @cubic_count = params.get_i32("cubicCount", 1)
  end

  def can_start?(info)
    info.effected.player?
  end

  def on_start(info)
    info.effected.acting_player.not_nil!.stat.max_cubic_count = @cubic_count
  end

  def on_action_time(info)
    info.skill.passive?
  end

  def on_exit(info)
    info.effected.acting_player.not_nil!.stat.max_cubic_count = 1
  end
end
