struct TransformLevelData
  @max_hp : Float64
  @max_mp : Float64
  @max_cp : Float64
  @regenerate_hp_rate : Float64
  @regenerate_mp_rate : Float64
  @regenerate_cp_rate : Float64

  getter level : Int32
  getter level_mod : Float64

  def initialize(set : StatsSet)
    @level = set.get_i32("val")
    @level_mod = set.get_f64("levelMod")
    @max_hp = set.get_f64("hp")
    @max_mp = set.get_f64("mp")
    @max_cp = set.get_f64("cp")
    @regenerate_hp_rate = set.get_f64("hpRegen")
    @regenerate_mp_rate = set.get_f64("mpRegen")
    @regenerate_cp_rate = set.get_f64("cpRegen")
  end

  def get_stats(stat : Stats) : Float64
    case stat
    when .max_hp?
      @max_hp
    when .max_mp?
      @max_mp
    when .max_cp?
      @max_cp
    when .regenerate_hp_rate?
      @regenerate_hp_rate
    when .regenerate_mp_rate?
      @regenerate_mp_rate
    when .regenerate_cp_rate?
      @regenerate_cp_rate
    else
      0.0
    end
  end
end
