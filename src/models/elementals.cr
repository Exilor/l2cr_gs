class Elementals
  private TABLE = {} of Int32 => ElementalItems

  NONE  = -1i8
  FIRE  =  0i8
  WATER =  1i8
  WIND  =  2i8
  EARTH =  3i8
  HOLY  =  4i8
  DARK  =  5i8

  FIRST_WEAPON_BONUS = 20
  NEXT_WEAPON_BONUS = 5
  ARMOR_BONUS = 6

  WEAPON_VALUES = {
    0, 25, 75, 150, 175, 225, 300, 325, 375, 450, 475, 525, 600, Int32::MAX
  }

  ARMOR_VALUES = {
    0, 12, 32, 60, 72, 90, 120, 132, 150, 180, 192, 210, 240, Int32::MAX
  }

  getter element, value

  def initialize(element : Int8, value : Int32)
    @element = element
    @value = value
    @boni = ElementalStatBoni.new(element, value)
  end

  def element=(element : Int8)
    @element = element
    @boni.element = element
  end

  def value=(value : Int32)
    @value = value
    @boni.value = value
  end

  def apply_bonus(pc : L2PcInstance, is_armor : Bool)
    @boni.apply_bonus(pc, is_armor)
  end

  def remove_bonus(pc : L2PcInstance)
    @boni.remove_bonus(pc)
  end

  def update_bonus(pc : L2PcInstance, is_armor : Bool)
    @boni.remove_bonus(pc)
    @boni.apply_bonus(pc, is_armor)
  end

  def to_s(io : IO)
    io << Elementals.get_element_name(@element) << " +" << @value
  end

  def self.get_item_element(item_id : Int) : Int8
    TABLE[item_id]?.try &.element || NONE
  end

  def self.get_item_elemental(item_id : Int) : ElementalItems?
    TABLE[item_id]?
  end

  def self.get_max_element_level(item_id : Int) : Int32
    TABLE[item_id]?.try &.type.max_level || -1
  end

  def self.get_element_name(element : Int) : String
    case element
    when FIRE  then "Fire"
    when WATER then "Water"
    when WIND  then "Wind"
    when EARTH then "Earth"
    when HOLY  then "Holy"
    when DARK  then "Dark"
    else "None"
    end
  end

  def self.get_element_id(name : String) : Int8
    case name.casecmp
    when "FIRE"  then FIRE
    when "WATER" then WATER
    when "WIND"  then WIND
    when "EARTH" then EARTH
    when "HOLY"  then HOLY
    when "DARK"  then DARK
    else NONE
    end
  end

  def self.get_opposite_element(element : Int8) : Int8
    element.even? ? element + 1 : element - 1
  end

  class ElementalStatBoni
    @active = false

    initializer elemental_type : Int8, elemental_value : Int32

    def apply_bonus(pc : L2PcInstance, is_armor : Bool)
      return if @active

      stat =
      case @elemental_type
      when FIRE  then is_armor ? Stats::FIRE_RES  : Stats::FIRE_POWER
      when WATER then is_armor ? Stats::WATER_RES : Stats::WATER_POWER
      when WIND  then is_armor ? Stats::WIND_RES  : Stats::WIND_POWER
      when EARTH then is_armor ? Stats::EARTH_RES : Stats::EARTH_POWER
      when DARK  then is_armor ? Stats::DARK_RES  : Stats::DARK_POWER
      else            is_armor ? Stats::HOLY_RES  : Stats::HOLY_POWER
      end

      pc.add_stat_func(FuncAdd.new(stat, 0x40, self, @elemental_value.to_f64))

      @active = true
    end

    def remove_bonus(pc : L2PcInstance)
      if @active
        pc.remove_stats_owner(self)
        @active = false
      end
    end

    def value=(val : Int32)
      @elemental_value = val
    end

    def element=(elem : Int8)
      @elemental_type = elem
    end
  end

  class ElementalItems < EnumClass
    getter element, item_id, type
    protected initializer element : Int8, item_id : Int32,
      type : ElementalItemType

    add(FIRE_STONE,      FIRE,   9546, ElementalItemType::Stone)
    add(WATER_STONE,     WATER,  9547, ElementalItemType::Stone)
    add(WIND_STONE,      WIND,   9549, ElementalItemType::Stone)
    add(EARTH_STONE,     EARTH,  9548, ElementalItemType::Stone)
    add(DIVINE_STONE,    HOLY,   9551, ElementalItemType::Stone)
    add(DARK_STONE,      DARK,   9550, ElementalItemType::Stone)

    add(FIRE_ROUGHORE,   FIRE,  10521, ElementalItemType::Roughore)
    add(WATER_ROUGHORE,  WATER, 10522, ElementalItemType::Roughore)
    add(WIND_ROUGHORE,   WIND,  10524, ElementalItemType::Roughore)
    add(EARTH_ROUGHORE,  EARTH, 10523, ElementalItemType::Roughore)
    add(DIVINE_ROUGHORE, HOLY,  10526, ElementalItemType::Roughore)
    add(DARK_ROUGHORE,   DARK,  10525, ElementalItemType::Roughore)

    add(FIRE_CRYSTAL,    FIRE,   9552, ElementalItemType::Crystal)
    add(WATER_CRYSTAL,   WATER,  9553, ElementalItemType::Crystal)
    add(WIND_CRYSTAL,    WIND,   9555, ElementalItemType::Crystal)
    add(EARTH_CRYSTAL,   EARTH,  9554, ElementalItemType::Crystal)
    add(DIVINE_CRYSTAL,  HOLY,   9557, ElementalItemType::Crystal)
    add(DARK_CRYSTAL,    DARK,   9556, ElementalItemType::Crystal)

    add(FIRE_JEWEL,      FIRE,   9558, ElementalItemType::Jewel)
    add(WATER_JEWEL,     WATER,  9559, ElementalItemType::Jewel)
    add(WIND_JEWEL,      WIND,   9561, ElementalItemType::Jewel)
    add(EARTH_JEWEL,     EARTH,  9560, ElementalItemType::Jewel)
    add(DIVINE_JEWEL,    HOLY,   9563, ElementalItemType::Jewel)
    add(DARK_JEWEL,      DARK,   9562, ElementalItemType::Jewel)

    # not yet supported by client (Freya pts)
    add(FIRE_ENERGY,     FIRE,   9564, ElementalItemType::Energy)
    add(WATER_ENERGY,    WATER,  9565, ElementalItemType::Energy)
    add(WIND_ENERGY,     WIND,   9567, ElementalItemType::Energy)
    add(EARTH_ENERGY,    EARTH,  9566, ElementalItemType::Energy)
    add(DIVINE_ENERGY,   HOLY,   9569, ElementalItemType::Energy)
    add(DARK_ENERGY,     DARK,   9568, ElementalItemType::Energy)

    each { |item| TABLE[item.item_id] = item }
  end


  class ElementalItemType < EnumClass
    getter max_level
    protected initializer max_level : Int32

    add(Stone,    3)
    add(Roughore, 3)
    add(Crystal,  6)
    add(Jewel,    9)
    add(Energy,   12)
  end
end
