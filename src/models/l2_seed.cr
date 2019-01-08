struct L2Seed
  @reward1 : Int32
  @reward2 : Int32
  @limit_crops : Int32
  @limit_seeds : Int32
  getter castle_id : Int32
  getter seed_id : Int32
  getter crop_id : Int32
  getter level : Int32
  getter mature_id : Int32
  getter seed_reference_price : Int32
  getter crop_reference_price : Int32
  getter? alternative : Bool

  def initialize(set : StatsSet)
    @crop_id = set.get_i32("id")
    @seed_id = set.get_i32("seedId")
    @level = set.get_i32("level")
    @mature_id = set.get_i32("mature_Id")
    @reward1 = set.get_i32("reward1")
    @reward2 = set.get_i32("reward2")
    @castle_id = set.get_i32("castleId")
    @alternative = set.get_bool("alternative")
    @limit_crops = set.get_i32("limit_crops")
    @limit_seeds = set.get_i32("limit_seed")

    item = ItemTable[@crop_id]?
    @crop_reference_price = item.try &.reference_price || 1
    @seed_reference_price = item.try &.reference_price || 1
  end

  def get_reward(type : Int32) : Int32
    type == 1 ? @reward1 : @reward2
  end

  def seed_limit : Int32
    @limit_seeds * Config.rate_drop_manor
  end

  def crop_limit : Int32
    @limit_crops * Config.rate_drop_manor
  end

  def seed_max_price : Int32
    @seed_reference_price * 10
  end

  def seed_min_price : Int32
    (@seed_reference_price * 0.6).to_i
  end

  def crop_max_price : Int32
    @crop_reference_price * 10
  end

  def crop_min_price : Int32
    (@crop_reference_price * 0.6).to_i
  end
end
