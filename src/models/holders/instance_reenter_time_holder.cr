require "../../enums/day_of_week"

struct InstanceReenterTimeHolder
  getter time = -1i64
  getter day : DayOfWeek?
  getter hour = -1
  getter minute = -1

  initializer time : Int64
  initializer day : DayOfWeek?, hour : Int32, minute : Int32
end
