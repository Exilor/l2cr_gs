class AuctionDateGenerator
  include Synchronizable

  FIELD_INTERVAL = "interval"
  FIELD_DAY_OF_WEEK = "day_of_week"
  FIELD_HOUR_OF_DAY = "hour_of_day"
  FIELD_MINUTE_OF_HOUR = "minute_of_hour"

  private MILLIS_IN_WEEK = Time.days_to_ms(7)

  @calendar = Calendar.new
  @interval : Int32
  @day_of_week : Int32
  @hour_of_day : Int32
  @minute_of_hour : Int32

  def initialize(config : StatsSet)
    @interval = config.get_i32(FIELD_INTERVAL, -1)
    fixed_day_week = config.get_i32(FIELD_DAY_OF_WEEK, -1) + 1
    @day_of_week = fixed_day_week > 7 ? 1 : fixed_day_week
    @hour_of_day = config.get_i32(FIELD_HOUR_OF_DAY, -1)
    @minute_of_hour = config.get_i32(FIELD_MINUTE_OF_HOUR, -1)

    check_day_of_week(-1)
    check_hour_of_day(-1)
    check_minute_of_hour(0)
  end

  def next_date(date : Int64) : Int64
    sync do
      @calendar.ms = date
      @calendar.millisecond = 0
      @calendar.second = 0
      @calendar.minute = @minute_of_hour
      @calendar.hour = @hour_of_day
      if @day_of_week > 0
        @calendar.day_of_week = @day_of_week
        return calc_dest_time(@calendar.ms, date, MILLIS_IN_WEEK)
      end

      calc_dest_time(@calendar.ms, date, Time.days_to_ms(@interval))
    end
  end

  private def calc_dest_time(time : Int64, date : Int64, add : Int64) : Int64
    if time < date
      time += ((date - time) / add) * add
      if time < date
        time += add
      end
    end

    time
  end

  private def check_day_of_week(default_value : Int32)
    if @day_of_week < 1 || @day_of_week > 7
      if default_value == -1 && @interval < 1
        tmp = @day_of_week == -1 ? "not found" : @day_of_week
        raise "Illegal value for '#{FIELD_DAY_OF_WEEK}': #{tmp}"
      end

      @day_of_week = default_value
    elsif @interval > 1
      raise "Illegal value for '#{FIELD_INTERVAL}' and '#{FIELD_DAY_OF_WEEK}': only one can be used"
    end
  end

  private def check_hour_of_day(default_value : Int32)
    if @hour_of_day < 0 || @hour_of_day > 23
      if default_value == -1
        tmp = @hour_of_day == -1 ? "not found" : @hour_of_day
        raise "Illegal value for '#{FIELD_HOUR_OF_DAY}': #{tmp}"
      end

      @hour_of_day = default_value
    end
  end

  private def check_minute_of_hour(default_value : Int32)
    if @minute_of_hour < 0 || @minute_of_hour > 59
      if default_value == -1
        tmp = @minute_of_hour == -1 ? "not found" : @minute_of_hour
        raise "Illegal value for '#{FIELD_MINUTE_OF_HOUR}': #{tmp}"
      end

      @minute_of_hour = default_value
    end
  end
end
