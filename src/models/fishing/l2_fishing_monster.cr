struct L2FishingMonster
  getter min_level : Int32, max_level : Int32, id : Int32, probability : Int32

  def initialize(set : StatsSet)
    @min_level = set.get_i32("userMinLevel")
    @max_level = set.get_i32 "userMaxLevel"
    @id = set.get_i32("fishingMonsterId")
    @probability = set.get_i32("probability")
  end
end
