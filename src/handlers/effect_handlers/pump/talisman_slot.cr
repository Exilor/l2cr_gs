class EffectHandler::TalismanSlot < AbstractEffect
  @slots : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super
    @slots = params.get_i32("slots", 0)
  end

  def can_start?(info)
    !!info.effected? && info.effected.player?
  end

  def on_start(info)
    info.effected.acting_player.stat.add_talisman_slots(@slots)
  end

  def on_action_time(info)
    info.skill.passive?
  end

  def on_exit(info)
    info.effected.acting_player.stat.add_talisman_slots(-@slots)
  end
end
