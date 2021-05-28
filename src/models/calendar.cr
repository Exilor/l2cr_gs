require "../enums/day_of_week"

class Calendar
  include Comparable(Calendar)
  include Comparable(Time)

  MILLISECOND = 0.001
  SECOND = 1
  MINUTE = 60
  HOUR = 3600
  DAY = 86_400

  SUNDAY = 1
  MONDAY = 2
  TUESDAY = 3
  WEDNESDAY = 4
  THURSDAY = 5
  FRIDAY = 6
  SATURDAY = 7

  enum Month : UInt8
    JANUARY
    FEBRUARY
    MARCH
    APRIL
    MAY
    JUNE
    JULY
    AUGUST
    SEPTEMBER
    OCTOBER
    NOVEMBER
  end

  {% for const in Month.constants %}
    {{const}} = Month::{{const}}
    {{const}}
  {% end %}

  property_initializer time : Time = Time.now

  def_equals_and_hash @time
  delegate day, ms, millisecond, second, minute, hour, day_of_year, year,
    monday?, tuesday?, wednesday?, thursday?, friday?, saturday?, sunday?,
    to: @time

  def to_s(format : String)
    @time.to_s(format)
  end

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

  def millisecond=(millisecond)
    @time = Time.from_ms(@time.ms - @time.millisecond + millisecond)
    self
  end

  def second=(second)
    @time = Time.from_s(@time.s - @time.second + second).to_local
    self
  end

  def minute=(min) # the minute of the current hour
    min = min.to_i64
    min *= MINUTE
    seconds = @time.minute * MINUTE

    @time = Time.from_s(@time.s - seconds + min).to_local

    self
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
      @time -= (dow &- 1).days
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

  def day_of_year=(day : Int)
    if day == 0
      day = 1
    end
    self.day += day - day_of_year
  end

  def ms=(ms : Int)
    @time = Time.from_ms(ms)
  end

  def month : Int32
    @time.month &- 1
  end

  def month=(month)
    difference = (month &- month()).abs
    if month > month()
      @time += difference.months
    else
      @time -= difference.months
    end
  end

  def year=(year)
    difference = (year &- @time.year).abs
    if year > @time.year
      @time += difference.years
    else
      @time -= difference.years
    end
  end

  enum Unit : UInt8
    MILLISECOND
    SECOND
    MINUTE
    HOUR
    DAY
    WEEK
    MONTH
  end

  def add(unit : Unit, value : Number)
    case unit
    when Unit::MILLISECOND
      add(value.milliseconds)
    when Unit::SECOND
      add(value.seconds)
    when Unit::MINUTE
      add(value.minutes)
    when Unit::HOUR
      add(value.hours)
    when Unit::DAY
      add(value.days)
    when Unit::WEEK
      add(value.weeks)
    when Unit::MONTH
      add(value.months)
    else
      raise ArgumentError.new("Invalid unit #{unit}")
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

  def get_minimum(unit : Unit) : Int
    case unit
    when Unit::HOUR, Unit::MINUTE, Unit::DAY, Unit::MONTH
      0
    else
      raise ArgumentError.new("#{unit} not handled in Calendar#get_minimum")
    end
  end

  def get_maximum(unit : Unit) : Int
    case unit
    when Unit::HOUR
      23
    when Unit::MINUTE
      59
    when Unit::DAY
      Time::DAYS_MONTH[month &+ 1]
    when Unit::MONTH
      11
    else
      raise ArgumentError.new("#{unit} not handled in Calendar#get_maximum")
    end
  end

  def to_s(io : IO)
    io.print("Calendar(", @time, ')')
  end

  def inspect(io : IO)
    to_s(io)
  end
end
