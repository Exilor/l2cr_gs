require "./char_known_list"

class NpcKnownList < CharKnownList
  @tracking_task : Scheduler::PeriodicTask?

  def add_known_object(object : L2Object) : Bool
    return false unless super

    npc = active_char

    if npc.npc? && object.is_a?(L2Character)
      OnNpcCreatureSee.new(npc, object, object.summon?).async(npc)
    end

    true
  end

  def get_distance_to_forget_object(object : L2Object) : Int32
    2 * get_distance_to_watch_object(object)
  end

  def get_distance_to_watch_object(object : L2Object) : Int32
    return 0 unless object.character?
    return 4000 if object.is_a?(L2FestivalGuideInstance)
    object.playable? ? 1500 : 500
  end

  def start_tracking_task
    if @tracking_task.nil? && active_char.aggro_range > 0
      task = TrackingTask.new(active_char)
      @tracking_task = ThreadPoolManager.schedule_ai_at_fixed_rate(task, 2000, 2000)
    end
  end

  def stop_tracking_task
    if task = @tracking_task
      task.cancel
      @tracking_task = nil
    end
  end

  def active_char : L2Npc
    super.as(L2Npc)
  end

  private struct TrackingTask
    initializer npc : L2Npc

    def call
      npc = @npc
      return unless npc.is_a?(L2Attackable)
      return unless npc.intention.move_to?
      npc.known_list.known_players.each_value do |pl|
        if pl.alive? && !pl.invul?
          if pl.inside_radius?(npc, npc.aggro_range, true, false)
            if npc.monster? || (npc.is_a?(L2GuardInstance) && pl.karma > 0)
              if npc.get_hating(pl) == 0
                npc.add_damage_hate(pl, 0, 0)
              end

              if !npc.intention.attack? && !npc.core_ai_disabled?
                WalkingManager.stop_moving(npc, false, true)
                npc.add_damage_hate(pl, 0, 100)
                npc.set_intention(AI::ATTACK, pl)
              end
            end
          end
        end
      end
    end
  end
end
