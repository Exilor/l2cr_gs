require "./vehicle_stat"

class ControllableAirshipStat < VehicleStat
  def move_speed : Float64
    (active_char.in_dock? || active_char.fuel > 0 ? super : super * 0.05).to_f64
  end

  def active_char
    super.as(L2ControllableAirshipInstance)
  end
end
