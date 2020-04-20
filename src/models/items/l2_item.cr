require "../events/listeners_container"
require "../../enums/material_type"
require "../../enums/crystal_type"
require "../../enums/item_type_1"
require "../../enums/item_type_2"
require "../../enums/action_type"
require "../elementals"
require "../conditions/condition"
require "../stats/func_template"

abstract class L2Item < ListenersContainer
  include Packets::Outgoing
  include Loggable

  SLOT_NONE       = 0x0000
  SLOT_UNDERWEAR  = 0x0001
  SLOT_R_EAR      = 0x0002
  SLOT_L_EAR      = 0x0004
  SLOT_LR_EAR     = 0x00006
  SLOT_NECK       = 0x0008
  SLOT_R_FINGER   = 0x0010
  SLOT_L_FINGER   = 0x0020
  SLOT_LR_FINGER  = 0x0030
  SLOT_HEAD       = 0x0040
  SLOT_R_HAND     = 0x0080
  SLOT_L_HAND     = 0x0100
  SLOT_GLOVES     = 0x0200
  SLOT_CHEST      = 0x0400
  SLOT_LEGS       = 0x0800
  SLOT_FEET       = 0x1000
  SLOT_BACK       = 0x2000
  SLOT_LR_HAND    = 0x4000
  SLOT_FULL_ARMOR = 0x8000
  SLOT_HAIR       = 0x010000
  SLOT_ALLDRESS   = 0x020000
  SLOT_HAIR2      = 0x040000
  SLOT_HAIRALL    = 0x080000
  SLOT_R_BRACELET = 0x100000
  SLOT_L_BRACELET = 0x200000
  SLOT_DECO       = 0x400000
  SLOT_BELT       = 0x10000000
  SLOT_WOLF       = -100
  SLOT_HATCHLING  = -101
  SLOT_STRIDER    = -102
  SLOT_BABYPET    = -103
  SLOT_GREATWOLF  = -104

  SLOT_MULTI_ALLWEAPON = SLOT_LR_HAND | SLOT_R_HAND

  @item_id : Int32
  @pre_conditions : Array(Condition)?
  @func_templates : Array(FuncTemplate)?
  @unequip_skill : SkillHolder?
  @skill_holder : Array(SkillHolder)?

  getter display_id : Int32
  getter name : String
  getter icon : String?
  getter weight : Int32
  getter material_type : MaterialType
  getter crystal_type : CrystalType
  getter equip_reuse_delay : Int32
  getter duration : Int32
  getter time : Int32
  getter auto_destroy_time : Int32
  getter body_part : Int32
  getter reference_price : Int32
  getter crystal_count : Int32
  getter enchantable : Int32
  getter default_action : ActionType
  getter default_enchant_level : Int32
  getter elementals : Array(Elementals)?
  getter use_skill_dis_time : Int32
  getter reuse_delay : Int32
  getter shared_reuse_group : Int32
  getter! type_1 : ItemType1
  getter! type_2 : ItemType2
  getter? stackable : Bool
  getter? sellable : Bool
  getter? droppable : Bool
  getter? destroyable : Bool
  getter? tradeable : Bool
  getter? depositable : Bool
  getter? elementable : Bool
  getter? quest_item : Bool
  getter? freightable : Bool
  getter? hero_item : Bool
  getter? for_npc : Bool
  getter? common : Bool
  getter? pvp_item : Bool
  getter? allows_self_resurrection : Bool
  getter? has_immediate_effect : Bool
  getter? has_ex_immediate_effect : Bool
  getter? oly_restricted_item : Bool

  def initialize(set)
    @item_id = set.get_i32("item_id")
    @display_id = set.get_i32("displayId", @item_id)
    @name = set.get_string("name")
    @icon = set.get_string("icon", nil)
    @weight = set.get_i32("weight", 0)
    @material_type = set.get_enum("material", MaterialType, MaterialType::STEEL)
    @equip_reuse_delay = set.get_i32("equip_reuse_delay", 0) * 1000
    @duration = set.get_i32("duration", -1)
    @time = set.get_i32("time", -1)
    @auto_destroy_time = set.get_i32("auto_destroy_time", -1) * 1000
    @body_part = ItemTable::SLOTS[set.get_string("bodypart", "none")]
    @reference_price = set.get_i32("price", 0)
    @crystal_type = set.get_enum("crystal_type", CrystalType, CrystalType::NONE)
    @crystal_count = set.get_i32("crystal_count", 0)

    @stackable = set.get_bool("is_stackable", false)
    @sellable = set.get_bool("is_sellable", true)
    @droppable = set.get_bool("is_dropable", true)
    @destroyable = set.get_bool("is_destroyable", true)
    @tradeable = set.get_bool("is_tradable", true)
    @depositable = set.get_bool("is_depositable", true)
    @elementable = set.get_bool("element_enabled", false)
    @enchantable = set.get_i32 "enchant_enabled", 0
    @quest_item = set.get_bool("is_questitem", false)
    @freightable = set.get_bool("is_freightable", false)
    @allows_self_resurrection = set.get_bool("allow_self_resurrection", false)
    @oly_restricted_item = set.get_bool("is_oly_restricted", false)
    @for_npc = set.get_bool("for_npc", false)

    @has_immediate_effect = set.get_bool("immediate_effect", false)
    @has_ex_immediate_effect = set.get_bool("ex_immediate_effect", false)

    @default_action = set.get_enum("default_action", ActionType, ActionType::NONE)
    @use_skill_dis_time = set.get_i32("useSkillDisTime", 0)
    @default_enchant_level = set.get_i32("enchanted", 0)
    @reuse_delay = set.get_i32("reuse_delay", 0)
    @shared_reuse_group = set.get_i32("shared_reuse_group", 0)

    @common = @item_id.between?(11605, 12361)
    @hero_item = @item_id.between?(6611, 6621) || @item_id.between?(9388, 9390) || @item_id == 6842
    @pvp_item = @item_id.between?(10667, 10835) || @item_id.between?(12852, 12977) || @item_id.between?(14363, 14525) || @item_id == 14528 || @item_id == 14529 || @item_id == 14558 || @item_id.between?(15913, 16024) || @item_id.between?(16134, 16147) || @item_id == 16149 || @item_id == 16151 || @item_id == 16153 || @item_id == 16155 || @item_id == 16157 || @item_id == 16159 || @item_id.between?(16168, 16176) || @item_id.between?(16179, 16220)

    skills = set.get_string("item_skill", nil)
    unless skills.nil? || skills.empty?
      skills_split = skills.split(';')
      skill_holder = [] of SkillHolder
      skills_split.each do |element|
        skill_split = element.split('-')
        id = skill_split[0].to_i
        level = skill_split[1].to_i
        skill_holder << SkillHolder.new(id, level)
      end
      @skill_holder = skill_holder.trim
    end

    skills = set.get_string("unequip_skill", nil)
    unless skills.nil? || skills.empty?
      info = skills.split('-')
      if info.size == 2
        id = info[0].to_i
        level = info[1].to_i
        if id > 0 && level > 0
          @unequip_skill = SkillHolder.new(id, level)
        end
      end
    end
  end

  def id : Int32
    @item_id
  end

  def magic_weapon? : Bool
    false
  end

  def item_mask : UInt32
    mask
  end

  def crystallizable? : Bool
    !@crystal_type.none? && @crystal_count > 0
  end

  def crystal_item_id : Int32
    @crystal_type.crystal_id
  end

  def item_grade : CrystalType
    crystal_type
  end

  def item_grade_s_plus : CrystalType
    Math.min(@crystal_type, CrystalType::S)
  end

  def get_crystal_count(enchant_level : Int) : Int32
    if enchant_level > 3
      case type_2
      when .shield_armor?, .accessory?
        @crystal_count + (crystal_type.crystal_enchant_bonus_armor * ((3 * enchant_level) - 6))
      when .weapon?
        @crystal_count + (crystal_type.crystal_enchant_bonus_weapon * ((2 * enchant_level) - 3))
      else
        @crystal_count
      end
    elsif enchant_level > 0
      case type_2
      when .shield_armor?, .accessory?
        @crystal_count + (crystal_type.crystal_enchant_bonus_armor * enchant_level)
      when .weapon?
        @crystal_count + (crystal_type.crystal_enchant_bonus_weapon * enchant_level)
      else
        @crystal_count
      end
    else
      @crystal_count
    end
  end

  def get_elemental(attribute : Int) : Elementals?
    @elementals.try &.find { |e| e.element == attribute }
  end

  def elementals=(element : Elementals)
    if elm = get_elemental(element.element)
      elm.value = element.value
    else
      (@elementals ||= [] of Elementals) << element
    end
  end

  def equippable? : Bool
    @body_part != 0 && !item_type.is_a?(EtcItemType)
  end

  def potion? : Bool
    item_type == EtcItemType::POTION
  end

  def elixir? : Bool
    item_type == EtcItemType::ELIXIR
  end

  def scroll? : Bool
    item_type == EtcItemType::SCROLL
  end

  def get_stat_funcs(item : L2ItemInstance, char : L2Character) : Indexable(AbstractFunction)
    unless templates = @func_templates
      return Slice(AbstractFunction).empty
    end

    if templates.empty?
      return Slice(AbstractFunction).empty
    end

    funcs = [] of AbstractFunction

    templates.each do |t|
      if f = t.get_func(char, char, item, item)
        funcs << f
      end
    end

    funcs
  end

  def attach(obj : FuncTemplate)
    case obj.stat
    when Stats::FIRE_RES, Stats::FIRE_POWER
      self.elementals = Elementals.new(Elementals::FIRE, obj.value.to_i)
    when Stats::WATER_RES, Stats::WATER_POWER
      self.elementals = Elementals.new(Elementals::WATER, obj.value.to_i)
    when Stats::WIND_RES, Stats::WIND_POWER
      self.elementals = Elementals.new(Elementals::WIND, obj.value.to_i)
    when Stats::EARTH_RES, Stats::EARTH_POWER
      self.elementals = Elementals.new(Elementals::EARTH, obj.value.to_i)
    when Stats::HOLY_RES, Stats::HOLY_POWER
      self.elementals = Elementals.new(Elementals::HOLY, obj.value.to_i)
    when Stats::DARK_RES, Stats::DARK_POWER
      self.elementals = Elementals.new(Elementals::DARK, obj.value.to_i)
    else
      # [automatically added else]
    end


    if temp = @func_templates
      temp << obj
    else
      @func_templates = [obj] of FuncTemplate
    end
  end

  def attach(obj : Condition)
    if conds = @pre_conditions
      unless conds.includes?(obj)
        conds << obj
      end
    else
      @pre_conditions = [obj] of Condition
    end
  end

  def has_skills? : Bool
    return false unless temp = @skill_holder
    !temp.empty?
  end

  def skills : Array(SkillHolder)?
    @skill_holder
  end

  def unequip_skill : Skill?
    @unequip_skill.try &.skill?
  end

  def check_condition(char : L2Character, object : L2Object, send_msg : Bool) : Bool
    if char.override_item_conditions? && !Config.gm_item_restriction
      return true
    end

    if oly_restricted_item? || hero_item?
      if char.is_a?(L2PcInstance) && char.in_olympiad_mode?
        if equippable?
          char.send_packet(SystemMessageId::THIS_ITEM_CANT_BE_EQUIPPED_FOR_THE_OLYMPIAD_EVENT)
        else
          char.send_packet(SystemMessageId::THIS_ITEM_IS_NOT_AVAILABLE_FOR_THE_OLYMPIAD_EVENT)
        end

        return false
      end
    end

    return true unless condition_attached?

    target = object.as?(L2Character)

    @pre_conditions.try &.each do |cond|
      unless cond.test(char, target, nil, nil)
        if char.is_a?(L2Summon)
          char.send_packet(SystemMessageId::PET_CANNOT_USE_ITEM)
          return false
        end

        if send_msg
          msg = cond.message
          msg_id = cond.message_id
          if msg
            char.send_message(msg)
          elsif msg_id != 0
            sm = SystemMessage[msg_id]
            if cond.add_name?
              sm.add_item_name(@item_id)
            end
            char.send_packet(sm)
          end
        end

        return false
      end
    end

    true
  end

  def condition_attached? : Bool
    return false unless conds = @pre_conditions
    !conds.empty?
  end

  def oly_restricted_item? : Bool
    @oly_restricted_item || Config.list_oly_restricted_items.includes?(@item_id)
  end

  def pet_item? : Bool
    item_type == EtcItemType::PET_COLLAR
  end

  def enchant_4_skill : Skill?
    # return nil
  end

  def to_s(io : IO)
    io << {{@type.stringify + "("}} << @name << ')'
  end

  abstract def item_type : ItemType
end
