require "./holders/skill_holder"

class ArmorSet
  getter legs = [] of Int32
  getter head = [] of Int32
  getter gloves = [] of Int32
  getter feet = [] of Int32
  getter shield = [] of Int32
  getter skills = [] of SkillHolder
  getter shield_skills = [] of SkillHolder
  getter enchant_6_skills = [] of SkillHolder
  property chest_id : Int32 = 0
  property con : Int32 = 0
  property dex : Int32 = 0
  property str : Int32 = 0
  property int : Int32 = 0
  property wit : Int32 = 0
  property men : Int32 = 0

  def contains_all?(pc : L2PcInstance) : Bool
    inv    = pc.inventory
    chest  = inv.chest_slot.try  &.id || 0
    legs   = inv.legs_slot.try   &.id || 0
    head   = inv.head_slot.try   &.id || 0
    gloves = inv.gloves_slot.try &.id || 0
    feet   = inv.feet_slot.try   &.id || 0

    contains_all?(chest, legs, head, gloves, feet)
  end

  def contains_all?(chest : Int32, legs : Int32, head : Int32, gloves : Int32, feet : Int32) : Bool
    return false if @chest_id != 0  && @chest_id != chest
    return false if !@legs.empty?   && !@legs.includes?(legs)
    return false if !@head.empty?   && !@head.includes?(head)
    return false if !@gloves.empty? && !@gloves.includes?(gloves)
    return false if !@feet.empty?   && !@feet.includes?(feet)
    true
  end

  def contains_item?(slot : Int32, item_id : Int32) : Bool
    case slot
    when Inventory::CHEST
      @chest_id == item_id
    when Inventory::LEGS
      @legs.includes?(item_id)
    when Inventory::HEAD
      @head.includes?(item_id)
    when Inventory::GLOVES
      @gloves.includes?(item_id)
    when Inventory::FEET
      @feet.includes?(item_id)
    else
      false
    end
  end

  def contains_shield?(shield_id : Int32) : Bool
    @shield.includes?(shield_id)
  end

  def contains_shield?(pc : L2PcInstance) : Bool
    return false unless shield_item = pc.inventory.lhand_slot
    @shield.includes?(shield_item.id)
  end

  def enchanted_6?(pc : L2PcInstance) : Bool
    return false unless contains_all?(pc)

    inv = pc.inventory

    chest_item = inv.chest_slot
    if chest_item.nil? || chest_item.enchant_level < 6
      return false
    end

    legs_item = inv.legs_slot
    if !@legs.empty? && (legs_item.nil? || legs_item.enchant_level < 6)
      return false
    end

    gloves_item = inv.gloves_slot
    if !@gloves.empty? && (gloves_item.nil? || gloves_item.enchant_level < 6)
      return false
    end

    head_item = inv.head_slot
    if !@head.empty? && (head_item.nil? || head_item.enchant_level < 6)
      return false
    end

    feet_item = inv.feet_slot
    if !@feet.empty? && (feet_item.nil? || feet_item.enchant_level < 6)
      return false
    end

    true
  end
end
