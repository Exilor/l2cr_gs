struct L2FishingMonster
  getter min_level : Int32
  getter max_level : Int32
  getter id : Int32
  getter probability : Int32

  def initialize(set : StatsSet)
    @min_level = set.get_i32("userMinLevel")
    @max_level = set.get_i32 "userMaxLevel"
    @id = set.get_i32("fishingMonsterId")
    @probability = set.get_i32("probability")
  end
end
