class TransformTemplate
  @data = {} of Int32 => TransformLevelData
  @base_stats = {} of Int32 => Float64
  @base_speed = {} of Int32 => Float64
  @base_defense = {} of Int32 => Int32

  getter collision_radius : Float64
  getter collision_height : Float64
  getter base_attack_type : WeaponType
  getter skills = [] of SkillHolder
  getter base_attack_range : Int32
  getter base_random_damage : Float64
  getter additional_skills = [] of AdditionalSkillHolder
  getter additional_items = [] of AdditionalItemHolder
  property basic_action_list : Packets::Outgoing::ExBasicActionList?

  def initialize(set : StatsSet)
    @collision_radius   = set.get_f64("radius", 0)
    @collision_height   = set.get_f64("height", 0)
    @base_attack_type   = set.get_enum("attackType", WeaponType, WeaponType::FIST)
    @base_attack_range  = set.get_i32("range", 40)
    @base_random_damage = set.get_f64("randomDamage", 0)

    add_speed(MoveType::WALK,      set.get_f64("walk", 0))
    add_speed(MoveType::RUN,       set.get_f64("run", 0))
    add_speed(MoveType::SLOW_SWIM, set.get_f64("waterWalk", 0))
    add_speed(MoveType::FAST_SWIM, set.get_f64("waterRun", 0))
    add_speed(MoveType::SLOW_FLY,  set.get_f64("flyWalk", 0))
    add_speed(MoveType::FAST_FLY,  set.get_f64("flyRun", 0))

    add_stats(Stats::POWER_ATTACK,       set.get_f64("pAtk", 0))
    add_stats(Stats::MAGIC_ATTACK,       set.get_f64("mAtk", 0))
    add_stats(Stats::POWER_ATTACK_RANGE, set.get_i32("range", 0))
    add_stats(Stats::POWER_ATTACK_SPEED, set.get_i32("attackSpeed", 0))
    add_stats(Stats::CRITICAL_RATE,      set.get_i32("critRate", 0))
    add_stats(Stats::STAT_STR,           set.get_i32("str", 0))
    add_stats(Stats::STAT_INT,           set.get_i32("int", 0))
    add_stats(Stats::STAT_CON,           set.get_i32("con", 0))
    add_stats(Stats::STAT_DEX,           set.get_i32("dex", 0))
    add_stats(Stats::STAT_WIT,           set.get_i32("wit", 0))
    add_stats(Stats::STAT_MEN,           set.get_i32("men", 0))

    add_defense(Inventory::CHEST,   set.get_i32("chest", 0))
    add_defense(Inventory::LEGS,    set.get_i32("legs", 0))
    add_defense(Inventory::HEAD,    set.get_i32("head", 0))
    add_defense(Inventory::FEET,    set.get_i32("feet", 0))
    add_defense(Inventory::GLOVES,  set.get_i32("gloves", 0))
    add_defense(Inventory::UNDER,   set.get_i32("underwear", 0))
    add_defense(Inventory::CLOAK,   set.get_i32("cloak", 0))
    add_defense(Inventory::REAR,    set.get_i32("rear", 0))
    add_defense(Inventory::LEAR,    set.get_i32("lear", 0))
    add_defense(Inventory::RFINGER, set.get_i32("rfinger", 0))
    add_defense(Inventory::LFINGER, set.get_i32("lfinger", 0))
    add_defense(Inventory::NECK,    set.get_i32("neck", 0))
  end

  private def add_speed(type, val)
    @base_speed[type.to_i] = val
  end

  def get_base_move_speed(type : MoveType) : Float64
    @base_speed.fetch(type.to_i, 0.0)
  end

  private def add_defense(type, val)
    @base_defense[type] = val
  end

  def get_defense(type : Int32) : Int32
    @base_defense.fetch(type, 0)
  end

  private def add_stats(stats, val)
    @base_stats[stats.to_i] = val.to_f
  end

  def get_stats(stats : Stats) : Float64
    @base_stats.fetch(stats.to_i, 0.0)
  end

  def add_skill(holder : SkillHolder)
    @skills << holder
  end

  def add_additional_skill(holder : AdditionalSkillHolder)
    @additional_skills << holder
  end

  def add_additional_item(holder : AdditionalItemHolder)
    @additional_items << holder
  end

  def has_basic_action_list? : Bool
    !!@basic_action_list
  end

  def add_level_data(data : TransformLevelData)
    @data[data.level] = data
  end

  def get_data(level : Int) : TransformLevelData?
    @data[level]?
  end
end
