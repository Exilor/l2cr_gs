require "../enums/day_of_week"

class Calendar
  include Comparable(Calendar)
  include Comparable(Time)

  MILLISECOND = 0.001
  SECOND = 1
  MINUTE = 60
  HOUR = 3600
  DAY = 86_400

  # MILLISECOND = 1.millisecond
  # SECOND = 1.second
  # MINUTE = 1.minute
  # HOUR = 1.hour
  # DAY = 1.day

  SUNDAY = 1
  MONDAY = 2
  TUESDAY = 3
  WEDNESDAY = 4
  THURSDAY = 5
  FRIDAY = 6
  SATURDAY = 7

  property time : Time = Time.now
  def_equals_and_hash @time
  forward_missing_to @time

  def <=>(other : Time)
    @time <=> other
  end

  def <=>(other : self)
    @time <=> other.time
  end

  def before?(other : Calendar)
    @time < other.time
  end

  def before?(other : Time)
    @time < other
  end

  def after?(other : Calendar)
    @time > other.time
  end

  def after?(other : Time)
    @time > other
  end

  def second
    @time.second
  end

  def second=(second)
    @time = Time.from_s(@time.s - @time.second + second).to_local
    self
  end

  def minute
    @time.minute
  end

  def minute=(min) # the minute of the current hour
    min *= MINUTE
    seconds = @time.minute * MINUTE

    @time = Time.from_s(@time.s - seconds + min).to_local

    self
  end

  def hour # the hour of the day e.g. 15 at 15:38
    @time.hour
  end

  def hour=(hour) # the hour of the day
    hour *= HOUR
    seconds = @time.hour * HOUR

    @time = Time.from_s(@time.s - seconds + hour).to_local

    self
  end

  def day=(day) # the day of the month (java calls it DATE)
    day *= DAY
    seconds = @time.day * DAY

    @time = Time.from_s(@time.s - seconds + day).to_local

    self
  end

  def day_of_week=(day)
    dow = @time.day_of_week.value
    if dow == 0
      @time -= 6.days
    else
      @time -= (dow - 1).days
    end

    case day
    when :MONDAY, MONDAY
      # already in monday
    when :TUESDAY, TUESDAY
      until @time.tuesday?
        @time += 1.day
      end
    when :WEDNESDAY, WEDNESDAY
      until @time.wednesday?
        @time += 1.day
      end
    when :THURSDAY, THURSDAY
      until @time.thursday?
        @time += 1.day
      end
    when :FRIDAY, FRIDAY
      until @time.friday?
        @time += 1.day
      end
    when :SATURDAY, SATURDAY
      until @time.saturday?
        @time += 1.day
      end
    when :SUNDAY, SUNDAY
      until @time.sunday?
        @time += 1.day
      end
    else
      raise ArgumentError.new
    end
  end

  def ms=(ms : Int) # setTimeInMillis
    @time = Time.from_ms(ms)
  end

  def add(unit : Symbol, value : Number)
    case unit
    when :MILLISECOND
      add(value.milliseconds)
    when :SECOND
      add(value.seconds)
    when :MINUTE
      add(value.minutes)
    when :HOUR
      add(value.hours)
    when :DAY
      add(value.days)
    when :WEEK
      add(value.weeks)
    when :MONTH
      add(value.months)
    else
      raise ArgumentError.new
    end
  end

  def add(value : Time::Span | Time::MonthSpan)
    @time += value
    self
  end

  def day_of_week
    case @time
    when .sunday?    then SUNDAY
    when .monday?    then MONDAY
    when .tuesday?   then TUESDAY
    when .wednesday? then WEDNESDAY
    when .thursday?  then THURSDAY
    when .friday?    then FRIDAY
    else SATURDAY
    end
  end
end
