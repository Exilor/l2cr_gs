require "../../enums/day_of_week"

struct InstanceReenterTimeHolder
  getter time
  getter day : DayOfWeek?
  getter hour = -1
  getter minute = -1

  def initialize(@time : Int64)
  end

  def initialize(@day : DayOfWeek?, @hour : Int32, @minute : Int32)
    @time = -1i64
  end
end
