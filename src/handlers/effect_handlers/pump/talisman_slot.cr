class EffectHandler::TalismanSlot < AbstractEffect
  @slots : Int32

  def initialize(attach_cond : Condition?, apply_cond : Condition?, set : StatsSet, params : StatsSet)
    super
    @slots = params.get_i32("slots", 0)
  end

  def can_start?(info : BuffInfo) : Bool
    info.effected.player?
  end

  def on_start(info : BuffInfo)
    info.effected.acting_player.not_nil!.stat.add_talisman_slots(@slots)
  end

  def on_action_time(info : BuffInfo) : Bool
    info.skill.passive?
  end

  def on_exit(info : BuffInfo)
    info.effected.acting_player.not_nil!.stat.add_talisman_slots(-@slots)
  end
end
