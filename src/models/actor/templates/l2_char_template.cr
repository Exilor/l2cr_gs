require "../../../enums/move_type"

class L2CharTemplate < ListenersContainer

  @move_type = Pointer(Float64).null
  getter base_str = 0
  getter base_dex = 0
  getter base_con = 0
  getter base_int = 0
  getter base_wit = 0
  getter base_men = 0
  getter base_hp_max = 0f32
  getter base_cp_max = 0f32
  getter base_mp_max = 0f32
  getter base_hp_reg = 0f32
  getter base_mp_reg = 0f32
  getter base_p_atk = 0
  getter base_m_atk = 0
  getter base_p_def = 0
  getter base_m_def = 0
  getter base_p_atk_spd = 0
  getter base_m_atk_spd = 0
  getter base_attack_range = 0
  getter random_damage = 0
  getter base_attack_type : WeaponType = WeaponType::NONE
  getter base_shld_def = 0
  getter base_shld_rate = 0
  getter base_crit_rate = 0
  getter base_m_crit_rate = 0
  getter base_breath = 0
  getter base_fire = 0
  getter base_wind = 0
  getter base_water = 0
  getter base_earth = 0
  getter base_holy = 0
  getter base_dark = 0
  getter base_fire_res = 0.0
  getter base_wind_res = 0.0
  getter base_water_res = 0.0
  getter base_earth_res = 0.0
  getter base_holy_res = 0.0
  getter base_dark_res = 0.0
  getter base_element_res = 0.0
  getter collision_radius = 0
  getter collision_height = 0
  getter f_collision_radius = 0.0
  getter f_collision_height = 0.0
  getter race = Race::NONE

  def initialize(set : StatsSet)
    set(set)
  end

  def set(set : StatsSet)
    # Base stats
    @base_str = set.get_i32("baseSTR", 0)
    @base_con = set.get_i32("baseCON", 0)
    @base_dex = set.get_i32("baseDEX", 0)
    @base_int = set.get_i32("baseINT", 0)
    @base_wit = set.get_i32("baseWIT", 0)
    @base_men = set.get_i32("baseMEN", 0)
    @base_hp_max = set.get_f32("baseHpMax", 0)
    @base_cp_max = set.get_f32("baseCpMax", 0)
    @base_mp_max = set.get_f32("baseMpMax", 0)
    @base_hp_reg = set.get_f32("baseHpReg", 0)
    @base_mp_reg = set.get_f32("baseMpReg", 0)
    @base_p_atk = set.get_i32("basePAtk", 0)
    @base_m_atk = set.get_i32("baseMAtk", 0)
    @base_p_def = set.get_i32("basePDef", 0)
    @base_m_def = set.get_i32("baseMDef", 0)
    @base_p_atk_spd = set.get_i32("basePAtkSpd", 300)
    @base_m_atk_spd = set.get_i32("baseMAtkSpd", 333)
    @base_shld_def = set.get_i32("baseShldDef", 0)
    @base_attack_range = set.get_i32("baseAtkRange", 40)
    @random_damage = set.get_i32("baseRndDam", 0)
    @base_attack_type = set.get_enum("baseAtkType", WeaponType, WeaponType::FIST)
    @base_shld_rate = set.get_i32("baseShldRate", 0)
    @base_crit_rate = set.get_i32("baseCritRate", 4)
    @base_m_crit_rate = set.get_i32("baseMCritRate", 0)

    # Special stats
    @base_breath = set.get_i32("baseBreath", 100)
    @base_fire = set.get_i32("baseFire", 0)
    @base_wind = set.get_i32("baseWind", 0)
    @base_water = set.get_i32("baseWater", 0)
    @base_earth = set.get_i32("baseEarth", 0)
    @base_holy = set.get_i32("baseHoly", 0)
    @base_dark = set.get_i32("baseDark", 0)
    @base_fire_res = set.get_f64("baseFireRes", 0)
    @base_wind_res = set.get_f64("baseWindRes", 0)
    @base_water_res = set.get_f64("baseWaterRes", 0)
    @base_earth_res = set.get_f64("baseEarthRes", 0)
    @base_holy_res = set.get_f64("baseHolyRes", 0)
    @base_dark_res = set.get_f64("baseDarkRes", 0)
    @base_element_res = set.get_f64("baseElementRes", 0)

    # Geometry
    @f_collision_height = set.get_f64("collisionHeight", 0)
    @f_collision_radius = set.get_f64("collisionRadius", 0)
    @collision_radius = @f_collision_radius.to_i
    @collision_height = @f_collision_height.to_i

    @move_type = Pointer(Float64).malloc(MoveType.size, 1.0)

    # Speed
    set_base_move_speed(MoveType::RUN, set.get_f64("baseRunSpd", 120))
    set_base_move_speed(MoveType::WALK, set.get_f64("baseWalkSpd", 50))
    set_base_move_speed(
      MoveType::FAST_SWIM,
      set.get_f64("baseSwimRunSpd", get_base_move_speed(MoveType::RUN))
    )
    set_base_move_speed(
      MoveType::SLOW_SWIM,
      set.get_f64("baseSwimWalkSpd", get_base_move_speed(MoveType::WALK))
    )
    set_base_move_speed(
      MoveType::FAST_FLY,
      set.get_f64("baseFlyRunSpd", get_base_move_speed(MoveType::RUN))
    )
    set_base_move_speed(
      MoveType::SLOW_FLY,
      set.get_f64("baseFlyWalkSpd", get_base_move_speed(MoveType::WALK))
    )
  end

  def get_base_move_speed(type : MoveType) : Float64
    @move_type[type.to_i]
  end

  def set_base_move_speed(type : MoveType, value : Float64)
    @move_type[type.to_i] = value
  end

  private EMPTY_SKILLS = {} of Int32 => Skill

  def skills : Hash(Int32, Skill)
    EMPTY_SKILLS
  end
end
