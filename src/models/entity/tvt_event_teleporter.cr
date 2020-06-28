class TvTEventTeleporter
  def initialize(pc : L2PcInstance, coordinates : Slice(Int32), fast_schedule : Bool, admin_remove : Bool)
    @pc = pc
    @coordinates = coordinates
    @admin_remove = admin_remove

    if fast_schedule
      delay = 0
    else
      if TvTEvent.started?
        delay = Config.tvt_event_respawn_teleport_delay * 1000
      else
        delay = Config.tvt_event_start_leave_teleport_delay * 1000
      end
    end

    ThreadPoolManager.schedule_general(self, delay)
  end

  def call
    if smn = @pc.summon
      smn.unsummon(@pc)
    end

    if Config.tvt_event_effects_removal == 0 || (Config.tvt_event_effects_removal == 1 && (@pc.team.none? || (@pc.in_duel? && !@pc.duel_state.interrupted?)))
      @pc.stop_all_effects_except_those_that_last_through_death
    end

    if @pc.in_duel?
      @pc.duel_state = DuelState::INTERRUPTED

    end

    tvt_instance = TvTEvent.tvt_event_instance
    if tvt_instance != 0
      if TvTEvent.started? && !@admin_remove
        @pc.instance_id = tvt_instance
      else
        @pc.instance_id = 0
      end
    else
      @pc.instance_id = 0
    end

    @pc.do_revive

    @pc.tele_to_location(
      @coordinates[0] + rand(101) - 50,
      @coordinates[1] + rand(101) - 50,
      @coordinates[2],
      false
    )

    if TvTEvent.started? && !@admin_remove
      team_id = TvTEvent.get_participant_team_id(@pc.l2id) + 1
      case team_id
      when 0
        @pc.team = Team::NONE
      when 1
        @pc.team = Team::BLUE
      when 2
        @pc.team = Team::RED
      end
    else
      @pc.team = Team::NONE
    end

    @pc.heal!
    @pc.broadcast_status_update
    @pc.broadcast_user_info
  end
end
