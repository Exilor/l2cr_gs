struct L2PetLevelData
  getter owner_exp_taken : Int32
  getter pet_max_exp : Int64
  getter pet_max_hp : Float32
  getter pet_max_mp : Float32
  getter pet_p_atk : Float32
  getter pet_p_def : Float32
  getter pet_m_atk : Float32
  getter pet_m_def : Float32
  getter pet_max_feed : Int32
  getter pet_feed_battle : Int32
  getter pet_feed_normal : Int32
  getter pet_regen_hp : Float32
  getter pet_regen_mp : Float32
  getter pet_soulshot : Int16
  getter pet_spiritshot : Int16
  getter walk_speed_on_ride : Float64
  getter run_speed_on_ride : Float64
  getter slow_swim_speed_on_ride : Float64
  getter fast_swim_speed_on_ride : Float64
  getter slow_fly_speed_on_ride : Float64
  getter fast_fly_speed_on_ride : Float64

  def initialize(set : StatsSet)
    @owner_exp_taken = set.get_i32("get_exp_type")
    @pet_max_exp = set.get_f64("exp").to_i64
    @pet_max_hp = set.get_f32("org_hp")
    @pet_max_mp = set.get_f32("org_mp")
    @pet_p_atk = set.get_f32("org_pattack")
    @pet_p_def = set.get_f32("org_pdefend")
    @pet_m_atk = set.get_f32("org_mattack")
    @pet_m_def = set.get_f32("org_mdefend")
    @pet_max_feed = set.get_i32("max_meal")
    @pet_feed_battle = set.get_i32("consume_meal_in_battle")
    @pet_feed_normal = set.get_i32("consume_meal_in_normal")
    @pet_regen_hp = set.get_f32("org_hp_regen")
    @pet_regen_mp = set.get_f32("org_mp_regen")
    @pet_soulshot = set.get_i16("soulshot_count")
    @pet_spiritshot = set.get_i16("spiritshot_count")
    @walk_speed_on_ride = set.get_f64("walkSpeedOnRide", 0)
    @run_speed_on_ride = set.get_f64("runSpeedOnRide", 0)
    @slow_swim_speed_on_ride = set.get_f64("slowSwimSpeedOnRide", 0)
    @fast_swim_speed_on_ride = set.get_f64("fastSwimSpeedOnRide", 0)
    @slow_fly_speed_on_ride = set.get_f64("slowFlySpeedOnRide", 0)
    @fast_fly_speed_on_ride = set.get_f64("fastFlySpeedOnRide", 0)
  end

  def get_speed_on_ride(mt : MoveType) : Float64
    case mt
    when .walk?
      @walk_speed_on_ride
    when .run?
      @run_speed_on_ride
    when .slow_swim?
      @slow_swim_speed_on_ride
    when .fast_swim?
      @fast_swim_speed_on_ride
    when .slow_fly?
      @slow_fly_speed_on_ride
    when .fast_fly?
      @fast_fly_speed_on_ride
    else
      0.0
    end
  end
end
