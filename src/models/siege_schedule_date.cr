struct SiegeScheduleDate
  getter day : Int32
  getter hour : Int32
  getter max_concurrent : Int32

  def initialize(set : StatsSet)
    @day = set.get_i32("day", Calendar::SUNDAY)
    @hour = set.get_i32("hour", 16)
    @max_concurrent = set.get_i32("maxConcurrent", 5)
  end
end
