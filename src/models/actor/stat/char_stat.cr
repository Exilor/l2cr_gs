require "../../../enums/trait_type"
require "../../../enums/stats"

class CharStat
  include Synchronizable

  {% for const in Stats.constants %}
    private {{const}} = Stats::{{const}}
  {% end %}

  getter attack_traits = Slice(Float32).new(TraitType.size, 1f32)
  getter defence_traits = Slice(Float32).new(TraitType.size, 1f32)
  getter traits_invul = Slice(Int32).new(TraitType.size)
  getter attack_traits_count = Slice(Int32).new(TraitType.size)
  getter defence_traits_count = Slice(Int32).new(TraitType.size)

  property level : Int32 = 1

  getter_initializer active_char : L2Character

  def calc_stat(stat : Stats, value : Number = 1.0, target : L2Character? = nil, skill : Skill? = nil) : Float64
    value = value.to_f64
    c = @active_char.calculators[stat.to_i]
    if c.nil? || c.empty?
      return value
    end

    if (pc = @active_char.acting_player) && pc.transformed?
      if transform = pc.transformation
        val = transform.get_stat(pc, stat)
        if val > 0
          value = val
        end
      end
    end

    value = c.calc(@active_char, target, skill, value)
    value <= 0 && stat.check_negative? ? 1.0 : value
  end

  def accuracy : Int32
    calc_stat(ACCURACY_COMBAT, 0).round.to_i
  end

  def attack_speed_multiplier : Float32
    ((1.1 * p_atk_spd) / @active_char.template.base_p_atk_spd).to_f32
  end

  # unused
  def get_critical_dmg(target : L2Character, value : Float64) : Float64
    calc_stat(CRITICAL_DAMAGE, value, target)
  end

  def get_critical_hit(target : L2Character?, skill : Skill?)
    val = @active_char.template.base_crit_rate
    val = calc_stat(CRITICAL_RATE, val, target, skill)

    unless @active_char.override_max_stats_value?
      val = Math.min(val, Config.max_pcrit_rate)
    end

    val.ceil.to_i
  end

  def get_critical_hit_pos(base : Int32) : Int32
    calc_stat(CRITICAL_RATE_POS, base).to_i
  end

  def get_evasion_rate(target : L2Character?) : Int32
    val = calc_stat(EVASION_RATE, 0, target).round.to_i

    if @active_char.override_max_stats_value?
      return val
    end

    Math.min(val, Config.max_evasion)
  end

  def str : Int32
    calc_stat(STAT_STR, @active_char.template.base_str).to_i
  end

  def dex : Int32
    calc_stat(STAT_DEX, @active_char.template.base_dex).to_i
  end

  def con : Int32
    calc_stat(STAT_CON, @active_char.template.base_con).to_i
  end

  def int : Int32
    calc_stat(STAT_INT, @active_char.template.base_int).to_i
  end

  def wit : Int32
    calc_stat(STAT_WIT, @active_char.template.base_wit).to_i
  end

  def men : Int32
    calc_stat(STAT_MEN, @active_char.template.base_men).to_i
  end

  def max_cp : Int32
    calc_stat(MAX_CP, @active_char.template.base_cp_max).to_i
  end

  def max_recoverable_cp : Int32
    calc_stat(MAX_RECOVERABLE_CP, max_cp).to_i
  end

  def max_hp : Int32
    calc_stat(MAX_HP, @active_char.template.base_hp_max).to_i
  end

  def max_recoverable_hp : Int32
    calc_stat(MAX_RECOVERABLE_HP, max_hp).to_i
  end

  def max_mp : Int32
    calc_stat(MAX_MP, @active_char.template.base_mp_max).to_i
  end

  def max_recoverable_mp : Int32
    calc_stat(MAX_RECOVERABLE_MP, max_mp).to_i
  end

  def get_magical_attack_range(skill : Skill?) : Int32
    if skill
      return calc_stat(MAGIC_ATTACK_RANGE, skill.cast_range, nil, skill).to_i
    end

    @active_char.template.base_attack_range
  end

  def get_m_atk(target : L2Character?, skill : Skill?) : Float64
    if Config.champion_enable && @active_char.champion?
      val = Config.champion_atk
    else
      val = 1.0
    end

    if @active_char.raid?
      val *= Config.raid_mattack_multiplier
    end

    val *= @active_char.template.base_m_atk

    calc_stat(MAGIC_ATTACK, val, target, skill)
  end

  def m_atk_spd : Int32
    if Config.champion_enable && @active_char.champion?
      val = Config.champion_spd_atk
    else
      val = 1.0
    end

    val *= @active_char.template.base_m_atk_spd

    val = calc_stat(MAGIC_ATTACK_SPEED, val)

    unless @active_char.override_max_stats_value?
      val = Math.min(val, Config.max_matk_speed)
    end

    val.to_i
  end

  def get_m_critical_hit(target : L2Character?, skill : Skill?) : Int32
    val = calc_stat(MCRITICAL_RATE, 1, target, skill) * 10

    unless @active_char.override_max_stats_value?
      val = Math.min(val, Config.max_mcrit_rate)
    end

    val.to_i
  end

  def get_m_def(target : L2Character?, skill : Skill?) : Float64
    val = @active_char.template.base_m_def

    if @active_char.raid?
      val *= Config.raid_mdefence_multiplier
    end

    calc_stat(MAGIC_DEFENCE, val, target, skill)
  end

  def movement_speed_multiplier : Float64
    if @active_char.inside_water_zone?
      if @active_char.running?
        val = get_base_move_speed(MoveType::FAST_SWIM)
      else
        val = get_base_move_speed(MoveType::SLOW_SWIM)
      end
    else
      if @active_char.running?
        val = get_base_move_speed(MoveType::RUN)
      else
        val = get_base_move_speed(MoveType::WALK)
      end
    end

    move_speed.to_f * (1.0 / val)
  end

  def run_speed : Float64
    if @active_char.inside_water_zone?
      val = swim_run_speed
    else
      val = get_base_move_speed(MoveType::RUN)
    end

    val <= 0 ? 0.0 : calc_stat(MOVE_SPEED, val)
  end

  def walk_speed : Float64
    if @active_char.inside_water_zone?
      val = swim_walk_speed
    else
      val = get_base_move_speed(MoveType::WALK)
    end

    val <= 0 ? 0.0 : calc_stat(MOVE_SPEED, val)
  end

  def swim_run_speed : Float64
    val = get_base_move_speed(MoveType::FAST_SWIM)
    val <= 0 ? 0.0 : calc_stat(MOVE_SPEED, val)
  end

  def swim_walk_speed : Float64
    val = get_base_move_speed(MoveType::SLOW_SWIM)
    val <= 0 ? 0.0 : calc_stat(MOVE_SPEED, val)
  end

  def get_base_move_speed(type : MoveType) : Float64
    @active_char.template.get_base_move_speed(type)
  end

  def move_speed : Float64
    if @active_char.inside_water_zone?
      return @active_char.running? ? swim_run_speed : swim_walk_speed
    end

    @active_char.running? ? run_speed : walk_speed
  end

  def get_m_reuse_rate(skill : Skill) : Float64
    calc_stat(MAGIC_REUSE_RATE, 1, nil, skill)
  end

  def get_p_atk(target : L2Character?) : Float64
    if Config.champion_enable && @active_char.champion?
      val = Config.champion_atk
    else
      val = 1.0
    end

    if @active_char.raid?
      val *= Config.raid_pattack_multiplier
    end

    val *= @active_char.template.base_p_atk

    calc_stat(POWER_ATTACK, val, target)
  end

  def p_atk_spd : Float64
    if Config.champion_enable && @active_char.champion?
      val = Config.champion_spd_atk
    else
      val = 1.0
    end

    val *= @active_char.template.base_p_atk_spd

    calc_stat(POWER_ATTACK_SPEED, val).round
  end

  def get_p_def(target : L2Character?) : Float64
    val = @active_char.template.base_p_def

    if @active_char.raid?
      calc_stat(POWER_DEFENCE, val * Config.raid_pdefence_multiplier, target)
    else
      calc_stat(POWER_DEFENCE, val, target)
    end
  end

  def physical_attack_range : Int32
    pc = @active_char.as?(L2PcInstance)
    if @active_char.transformed? && pc && (transform = pc.transformation)
      val = transform.get_base_attack_range(pc)
    elsif weapon = @active_char.active_weapon_item
      val = weapon.base_attack_range
    else
      val = @active_char.template.base_attack_range
    end

    calc_stat(POWER_ATTACK_RANGE, val).to_i
  end

  def physical_attack_angle : Int32
    if weapon_item = @active_char.active_weapon_item
      return weapon_item.base_attack_angle
    end

    120
  end

  def get_weapon_reuse_modifier(target : L2Character?) : Float64
    calc_stat(ATK_REUSE, 1, target)
  end

  def shld_def : Int32
    calc_stat(SHIELD_DEFENCE, 0).to_i
  end

  def get_mp_consume2(skill : Skill) : Int32
    val = skill.mp_consume2

    if skill.dance? && Config.dance_consume_additional_mp
      if @active_char.dance_count > 0
        next_dance_mp_cost = val.fdiv(2).ceil
        val += @active_char.dance_count * next_dance_mp_cost
      end
    end

    val = calc_stat(MP_CONSUME, val, nil, skill)

    if skill.dance?
      calc_stat(DANCE_MP_CONSUME_RATE, val)
    elsif skill.magic?
      calc_stat(MAGICAL_MP_CONSUME_RATE, val)
    else
      calc_stat(PHYSICAL_MP_CONSUME_RATE, val)
    end
    .to_i
  end

  def get_mp_consume1(skill : Skill) : Int32
    calc_stat(MP_CONSUME, skill.mp_consume1, nil, skill).to_i
  end

  def attack_element : Int8
    if weapon = @active_char.active_weapon_instance
      element = weapon.attack_element_type
      return element.to_i8 if element >= 0
    end

    val = -2i8
    max = 0
    template = @active_char.template

    fire  = calc_stat(FIRE_POWER,  template.base_fire)
    water = calc_stat(WATER_POWER, template.base_water)
    wind  = calc_stat(WIND_POWER,  template.base_wind)
    earth = calc_stat(EARTH_POWER, template.base_earth)
    holy  = calc_stat(HOLY_POWER,  template.base_holy)
    dark  = calc_stat(DARK_POWER,  template.base_dark)

    val, max = 0i8, fire  if fire  > max
    val, max = 1i8, water if water > max
    val, max = 2i8, wind  if wind  > max
    val, max = 3i8, earth if earth > max
    val, max = 4i8, holy  if holy  > max
    val, max = 5i8, dark  if dark  > max

    val
  end

  def get_attack_element_value(attack_attribute : Int) : Int32
    case attack_attribute
    when Elementals::FIRE
      calc_stat(FIRE_POWER, @active_char.template.base_fire)
    when Elementals::WATER
      calc_stat(WATER_POWER, @active_char.template.base_water)
    when Elementals::WIND
      calc_stat(WIND_POWER, @active_char.template.base_wind)
    when Elementals::EARTH
      calc_stat(EARTH_POWER, @active_char.template.base_earth)
    when Elementals::HOLY
      calc_stat(HOLY_POWER, @active_char.template.base_holy)
    when Elementals::DARK
      calc_stat(DARK_POWER, @active_char.template.base_dark)
    else
      0
    end
    .to_i
  end

  def get_defense_element_value(defense_attribute : Int) : Int32
    case defense_attribute
    when Elementals::FIRE
      calc_stat(FIRE_RES, @active_char.template.base_fire_res)
    when Elementals::WATER
      calc_stat(WATER_RES, @active_char.template.base_water_res)
    when Elementals::WIND
      calc_stat(WIND_RES, @active_char.template.base_wind_res)
    when Elementals::EARTH
      calc_stat(EARTH_RES, @active_char.template.base_earth_res)
    when Elementals::HOLY
      calc_stat(HOLY_RES, @active_char.template.base_holy_res)
    when Elementals::DARK
      calc_stat(DARK_RES, @active_char.template.base_dark_res)
    else
      @active_char.template.base_element_res
    end
    .to_i
  end

  def get_attack_trait(type : TraitType) : Float32
    @attack_traits[type.to_i]
  end

  def has_attack_trait?(type : TraitType) : Bool
    @attack_traits_count[type.to_i] > 0
  end

  def get_defence_trait(type : TraitType) : Float32
    @defence_traits[type.to_i]
  end

  def has_defence_trait?(type : TraitType) : Bool
    @defence_traits_count[type.to_i] > 0
  end

  def trait_invul?(type : TraitType) : Bool
    @traits_invul[type.to_i] > 0
  end

  def max_buff_count : Int32
    calc_stat(ENLARGE_ABNORMAL_SLOT, Config.buffs_max_amount).to_i
  end
end
