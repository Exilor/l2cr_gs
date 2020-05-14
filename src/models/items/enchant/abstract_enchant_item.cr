abstract class AbstractEnchantItem
  private ENCHANT_TYPES = {
    EtcItemType::ANCIENT_CRYSTAL_ENCHANT_AM,
    EtcItemType::ANCIENT_CRYSTAL_ENCHANT_WP,
    EtcItemType::BLESS_SCRL_ENCHANT_AM,
    EtcItemType::BLESS_SCRL_ENCHANT_WP,
    EtcItemType::SCRL_ENCHANT_AM,
    EtcItemType::SCRL_ENCHANT_WP,
    EtcItemType::SCRL_INC_ENCHANT_PROP_AM,
    EtcItemType::SCRL_INC_ENCHANT_PROP_WP,
  }

  getter id : Int32
  getter bonus_rate : Float64
  getter grade : CrystalType
  getter max_enchant_level : Int32

  def initialize(set : StatsSet)
    @id = set.get_i32("id")
    if ItemTable[@id]?.nil?
      raise "Item with id #{@id} not found"
    elsif !ENCHANT_TYPES.includes?(item.item_type)
      raise "Item with id #{@id} not in AbstractEnchantItem::ENCHANT_TYPES " \
        "(item_type: #{item.item_type})"
    end

    @grade = set.get_enum("targetGrade", CrystalType, CrystalType::NONE)
    @max_enchant_level = set.get_i32("maxEnchant", 65535)
    @bonus_rate = set.get_f64("bonusRate", 0)
  end

  def item : L2Item
    ItemTable[@id]
  end

  def valid?(item_to_enchant : L2ItemInstance?, support_item : EnchantSupportItem?) : Bool
    unless item_to_enchant
      return false
    end

    if item_to_enchant.enchantable == 0
      return false
    end

    unless valid_item_type?(item_to_enchant.template.type_2)
      return false
    end

    if @max_enchant_level != 0
      if item_to_enchant.enchant_level > @max_enchant_level
        return false
      end
    end

    @grade == item_to_enchant.template.item_grade_s_plus
  end

  private def valid_item_type?(type2 : ItemType2) : Bool
    case type2
    when ItemType2::WEAPON
      weapon?
    when ItemType2::SHIELD_ARMOR, ItemType2::ACCESSORY
      !weapon?
    else
      false
    end
  end

  abstract def weapon? : Bool
end
