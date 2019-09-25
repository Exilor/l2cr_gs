module GameTimer
  extend self
  extend Synchronizable
  extend Loggable
  extend Cancellable

  TICKS_PER_SECOND       = 10
  MILLIS_IN_TICK         = 1_000 // TICKS_PER_SECOND
  IG_DAYS_PER_DAY        = 6
  MILLIS_PER_IG_DAY      = (3_600_000 * 24) // IG_DAYS_PER_DAY
  SECONDS_PER_IG_DAY     = MILLIS_PER_IG_DAY // 1_000
  MINUTES_PER_IG_DAY     = SECONDS_PER_IG_DAY // 60
  TICKS_PER_IG_DAY       = SECONDS_PER_IG_DAY * TICKS_PER_SECOND
  TICKS_SUN_STATE_CHANGE = TICKS_PER_IG_DAY // 4

  private MOVING_OBJECTS = Set(L2Character).new
  private REFERENCE_TIME = Time.now.at_beginning_of_day.ms

  def load
    spawn run
  end

  private def run
    night = night?
    change_mode = ->DayNightSpawnManager.notify_change_mode

    until cancelled?
      next_tick = Time.ms &+ 100

      sync do
        begin
          MOVING_OBJECTS.reject! &.update_position
        rescue e
          error "Error updating the position of moving objects."
          error e
        end
      end

      sleep_time = next_tick &- Time.ms
      if sleep_time > 0
        sleep(sleep_time.milliseconds)
      end

      if night != night?
        night = !night
        ThreadPoolManager.execute_ai(change_mode)
      end
    end
  end

  def register(char : L2Character)
    sync { MOVING_OBJECTS << char }
  end

  def ticks : Int32
    ((Time.ms - REFERENCE_TIME) // MILLIS_IN_TICK).to_i32
  end

  def time : Int32
    (ticks % TICKS_PER_IG_DAY) // MILLIS_IN_TICK
  end

  def hour : Int32
    time // 60
  end

  def minute : Int32
    time % 60
  end

  def night? : Bool
    hour < 6
  end
end
