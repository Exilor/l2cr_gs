class EffectHandler::CubicMastery < AbstractEffect
  @cubic_count : Int32

  def initialize(attach_cond : Condition?, apply_cond : Condition?, set : StatsSet, params : StatsSet)
    super
    @cubic_count = params.get_i32("cubicCount", 1)
  end

  def can_start?(info : BuffInfo) : Bool
    info.effected.player?
  end

  def on_start(info : BuffInfo)
    info.effected.acting_player.not_nil!.stat.max_cubic_count = @cubic_count
  end

  def on_action_time(info : BuffInfo) : Bool
    info.skill.passive?
  end

  def on_exit(info : BuffInfo)
    info.effected.acting_player.not_nil!.stat.max_cubic_count = 1
  end
end
