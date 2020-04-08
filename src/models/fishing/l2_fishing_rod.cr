struct L2FishingRod
  getter id : Int32, item_id : Int32, level : Int32
  getter name : String
  getter damage : Float64

  def initialize(set : StatsSet)
    @id = set.get_i32("fishingRodId")
    @item_id = set.get_i32("fishingRodItemId")
    @level = set.get_i32("fishingRodLevel")
    @name = set.get_string("fishingRodName")
    @damage = set.get_f64("fishingRodDamage")
  end
end
