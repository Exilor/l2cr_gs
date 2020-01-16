struct TransformLevelData
  @stats = {} of Int32 => Float64

  getter level : Int32
  getter level_mod : Float64

  def initialize(set : StatsSet)
    @level = set.get_i32("val")
    @level_mod = set.get_f64("levelMod")
    @stats = {
      Stats::MAX_HP.to_i => set.get_f64("hp"),
      Stats::MAX_MP.to_i => set.get_f64("mp"),
      Stats::MAX_CP.to_i => set.get_f64("cp"),
      Stats::REGENERATE_HP_RATE.to_i => set.get_f64("hpRegen"),
      Stats::REGENERATE_MP_RATE.to_i => set.get_f64("mpRegen"),
      Stats::REGENERATE_CP_RATE.to_i => set.get_f64("cpRegen")
    }
  end

  def get_stats(stats : Stats) : Float64
    @stats.fetch(stats.to_i, 0.0)
  end
end
