struct DateRange
  getter_initializer start_date = Time.local, end_date = Time.local

  def self.parse(date_range : String, format : String) : self
    date = date_range.split('-')
    if date.size == 2
      from = Time.parse(date[0], format, Time::Location.local)
      to = Time.parse(date[1], format, Time::Location.local)

      return new(from, to)
    end

    new(t = Time.local, t)
  end

  def valid? : Bool
    @start_date < @end_date
  end

  def within_range?(other : Time)
    (@start_date..@end_date).includes?(other)
  end

  def to_s(io : IO)
    io.print({{@type.stringify + "("}}, start_date, "..", end_date, ')')
  end
end
