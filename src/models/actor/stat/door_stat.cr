require "./char_stat"

class DoorStat < CharStat
  property upgrade_hp_ratio : Int32 = 1

  def max_hp : Int32
    super * @upgrade_hp_ratio
  end

  def active_char : L2DoorInstance
    super.as(L2DoorInstance)
  end
end
