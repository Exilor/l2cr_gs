module TvTManager
  extend self
  extend Loggable

  @@task : TvTStartTask?

  def load
    if Config.tvt_event_enabled
      TvTEvent.init
      schedule_event_start
      info "Started."
    else
      info "Disabled."
    end
  end

  def schedule_event_start
    now = Calendar.new
    next_start_time = nil
    test_start_time = nil
    Config.tvt_event_interval.each do |time|
      test_start_time = Calendar.new
      split_time = time.split(':')
      test_start_time.hour = split_time[0].to_i
      test_start_time.minute = split_time[1].to_i
      # If the date is in the past, make it the next day (Example: Checking for "1:00", when the time is 23:57.)
      if test_start_time.ms < now.ms
        test_start_time.add(:DAY, 1)
      end
      # Check for the test date to be the minimum (smallest in the specified list)
      if next_start_time.nil? || test_start_time.ms < next_start_time.ms
        next_start_time = test_start_time
      end
    end
    if next_start_time
      @@task = task = TvTStartTask.new(self, next_start_time.ms)
      ThreadPoolManager.execute_general(task)
    end
  rescue e
    warn "Error figuring out a start time. Check TvTEventInterval in config file."
  end

  def start_reg
    if !TvTEvent.start_participation
      Broadcast.to_all_online_players("TvT Event: Event was cancelled.")
      warn "Error spawning event npc for participation."

      schedule_event_start
    else
      Broadcast.to_all_online_players("TvT Event: Registration opened for #{Config.tvt_event_participation_time} minute(s).")

      # schedule registration end
      @@task.not_nil!.start_time = Time.ms + (60000i64 * Config.tvt_event_participation_time)
      ThreadPoolManager.execute_general(@@task.not_nil!)
    end
  end

  def start_event
    if !TvTEvent.start_fight
      Broadcast.to_all_online_players("TvT Event: Event cancelled due to lack of participation.")
      info "Event aborted due to lack of participation."

      schedule_event_start
    else
      task = @@task.not_nil!
      TvTEvent.message_all_participants("TvT Event: Teleporting participants to an arena in #{Config.tvt_event_start_leave_teleport_delay} second(s).")
      task.start_time = Time.ms + (60000i64 * Config.tvt_event_running_time)
      ThreadPoolManager.execute_general(task)
    end
  end

  def end_event
    Broadcast.to_all_online_players(TvTEvent.calculate_rewards)
    TvTEvent.message_all_participants("TvT Event: Teleporting back to the registration npc in #{Config.tvt_event_start_leave_teleport_delay} second(s).")
    TvTEvent.stop_fight

    schedule_event_start
  end

  def skip_delay
    task = @@task.not_nil!
    unless task.next_run.done?
      task.next_run.cancel
      task.start_time = Time.ms
      ThreadPoolManager.execute_general(task)
    end
  end

  class TvTStartTask
    getter! next_run : TaskScheduler::DelayedTask
    property start_time : Int64

    initializer manager : TvTManager, start_time : Int64

    def call
      delay = ((@start_time - Time.ms) / 1000).round.to_i

      if delay > 0
        announce(delay)
      end

      next_msg = 0
      if delay > 3600
        next_msg = delay - 3600
      elsif delay > 1800
        next_msg = delay - 1800
      elsif delay > 900
        next_msg = delay - 900
      elsif delay > 600
        next_msg = delay - 600
      elsif delay > 300
        next_msg = delay - 300
      elsif delay > 60
        next_msg = delay - 60
      elsif delay > 5
        next_msg = delay - 5
      elsif delay > 0
        next_msg = delay
      else
        # start
        if TvTEvent.inactive?
          @manager.start_reg
        elsif TvTEvent.participating?
          @manager.start_event
        else
          @manager.end_event
        end
      end

      if delay > 0
        @next_run = ThreadPoolManager.schedule_general(self, next_msg * 1000)
      end
    end

    private def announce(time)
      if time >= 3600 && time % 3600 == 0
        if TvTEvent.participating?
          Broadcast.to_all_online_players("TvT Event: #{time // 60 // 60} hour(s) until registration is closed!")
        elsif TvTEvent.started?
          TvTEvent.message_all_participants("TvT Event: #{time // 60 // 60} hour(s) until event is finished!")
        end
      elsif time >= 60
        if TvTEvent.participating?
          Broadcast.to_all_online_players("TvT Event: #{time // 60} minute(s) until registration is closed!")
        elsif TvTEvent.started?
          TvTEvent.message_all_participants("TvT Event: #{time // 60} minute(s) until the event is finished!")
        end
      else
        if TvTEvent.participating?
          Broadcast.to_all_online_players("TvT Event: #{time} second(s) until registration is closed!")
        elsif TvTEvent.started?
          TvTEvent.message_all_participants("TvT Event: #{time} second(s) until the event is finished!")
        end
      end
    end
  end
end
