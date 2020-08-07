require "./l2_char_template"
require "../../location"

class L2PcTemplate < L2CharTemplate
  @base_hp : Slice(Float32)
  @base_mp : Slice(Float32)
  @base_cp : Slice(Float32)
  @_base_hp_reg : Slice(Float64) # @base_hp_reg already exist in super as Float32
  @_base_mp_reg : Slice(Float64) # @base_mp_reg already exist in super as Float32
  @base_cp_reg : Slice(Float64)
  @base_safe_fall_height : Int32
  @base_slot_def : Hash(Int32, Int32)

  getter class_id : ClassId
  getter f_collision_radius_female : Float64
  getter f_collision_height_female : Float64

  def initialize(set : StatsSet)
    super(set)

    @class_id = ClassId[set.get_i32("classId")]
    @race = @class_id.race

    @base_hp = Slice(Float32).new(Config.max_player_level &+ 1)
    @base_mp = Slice(Float32).new(Config.max_player_level &+ 1)
    @base_cp = Slice(Float32).new(Config.max_player_level &+ 1)
    @_base_hp_reg = Slice(Float64).new(Config.max_player_level &+ 1)
    @_base_mp_reg = Slice(Float64).new(Config.max_player_level &+ 1)
    @base_cp_reg = Slice(Float64).new(Config.max_player_level &+ 1)

    @base_slot_def = {
      Inventory::CHEST   => set.get_i32("basePDefchest", 0),
      Inventory::LEGS    => set.get_i32("basePDeflegs", 0),
      Inventory::HEAD    => set.get_i32("basePDefhead", 0),
      Inventory::FEET    => set.get_i32("basePDeffeet", 0),
      Inventory::GLOVES  => set.get_i32("basePDefgloves", 0),
      Inventory::UNDER   => set.get_i32("basePDefunderwear", 0),
      Inventory::CLOAK   => set.get_i32("basePDefcloak", 0),
      Inventory::REAR    => set.get_i32("baseMDefrear", 0),
      Inventory::LEAR    => set.get_i32("baseMDeflear", 0),
      Inventory::RFINGER => set.get_i32("baseMDefrfinger", 0),
      Inventory::LFINGER => set.get_i32("baseMDefrfinger", 0),
      Inventory::NECK    => set.get_i32("baseMDefneck", 0)
    }

    @f_collision_radius_female = set.get_f64("collisionFemaleradius")
    @f_collision_height_female = set.get_f64("collisionFemaleheight")

    @base_safe_fall_height = set.get_i32("baseSafeFall", 333)
  end

  def set_upgain_value(param : String, level : Int32, val : Float64)
    case param
    when "hp"
      @base_hp[level] = val.to_f32
    when "mp"
      @base_mp[level] = val.to_f32
    when "cp"
      @base_cp[level] = val.to_f32
    when "hpRegen"
      @_base_hp_reg[level] = val.to_f64
    when "mpRegen"
      @_base_mp_reg[level] = val.to_f64
    when "cpRegen"
      @base_cp_reg[level] = val.to_f64
    else
      raise "Wrong param for L2PcTemplate#set_upgain_value: " + param
    end
  end

  def get_base_hp_max(level : Int32) : Float32
    @base_hp[level]
  end

  def get_base_hp_regen(level : Int32) : Float64
    @_base_hp_reg[level]
  end

  def get_base_mp_max(level : Int32) : Float32
    @base_mp[level]
  end

  def get_base_mp_regen(level : Int32) : Float64
    @_base_mp_reg[level]
  end

  def get_base_cp_max(level : Int32) : Float32
    @base_cp[level]
  end

  def get_base_cp_regen(level : Int32) : Float64
    @base_cp_reg[level]
  end

  def get_base_def_by_slot(slot : Int32) : Int32
    @base_slot_def.fetch(slot, 0)
  end

  def safe_fall_height : Int32
    @base_safe_fall_height
  end
end
