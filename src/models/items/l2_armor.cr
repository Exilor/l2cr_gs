require "./l2_item"

require "../../enums/armor_type"

class L2Armor < L2Item
  @enchant_4_skill: SkillHolder?

  getter item_type : ArmorType

  def initialize(set)
    super

    @item_type = set.get_enum("armor_type", ArmorType, ArmorType::NONE)

    if @body_part == SLOT_NECK || @body_part & SLOT_L_EAR != 0 || @body_part & SLOT_L_FINGER != 0 || @body_part & SLOT_R_BRACELET != 0 || @body_part & SLOT_L_BRACELET != 0
      @type_1 = ItemType1::WEAPON_RING_EARRING_NECKLACE
      @type_2 = ItemType2::ACCESSORY
    else
      if @item_type == ArmorType::NONE && @body_part == SLOT_L_HAND
        @item_type = ArmorType::SHIELD
      end
      @type_1 = ItemType1::SHIELD_ARMOR
      @type_2 = ItemType2::SHIELD_ARMOR
    end

    if skill = set.get_string("enchant4_skill", nil)
      info = skill.split('-')
      if info.size == 2
        id = info.first.to_i
        level = info.last.to_i
        if id > 0 && level > 0
          @enchant_4_skill = SkillHolder.new(id, level)
        end
      end
    end
  end

  def mask : UInt32
    item_type.mask.to_u32
  end

  def enchant_4_skill : Skill?
    @enchant_4_skill.try &.skill
  end
end
