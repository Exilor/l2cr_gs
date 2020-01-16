require "./abstract_enchant_item"
require "./enchant_result_type"

class EnchantScroll < AbstractEnchantItem
  @items : Set(Int32)?

  getter scroll_group_id : Int32
  getter? weapon : Bool
  getter? blessed : Bool
  getter? safe : Bool

  def initialize(set : StatsSet)
    super

    @scroll_group_id = set.get_i32("scrollGroupId", 0)
    type = item.item_type
		@weapon = type == EtcItemType::ANCIENT_CRYSTAL_ENCHANT_WP || type == EtcItemType::BLESS_SCRL_ENCHANT_WP || type == EtcItemType::SCRL_ENCHANT_WP
		@blessed = type == EtcItemType::BLESS_SCRL_ENCHANT_AM || type == EtcItemType::BLESS_SCRL_ENCHANT_WP
		@safe = type == EtcItemType::ANCIENT_CRYSTAL_ENCHANT_AM || type == EtcItemType::ANCIENT_CRYSTAL_ENCHANT_WP
  end

  def add_item(item_id : Int32)
    (@items ||= Set(Int32).new) << item_id
  end

  def valid?(item_to_enchant : L2ItemInstance, support_item : EnchantSupportItem?) : Bool
    items = @items
    if items && !items.includes?(item_to_enchant.id)
      return false
    elsif support_item
      return false if blessed?
      return false unless support_item.valid?(item_to_enchant, support_item)
      return false if support_item.weapon? != weapon?
    end

    super
  end

  def get_chance(pc : L2PcInstance, enchant_item : L2ItemInstance) : Float64
    unless EnchantItemGroupsData.get_scroll_group(@scroll_group_id)
      warn { "Enchant scroll group #{id} does not exist." }
      return -1f64
    end

    group = EnchantItemGroupsData.get_item_group(enchant_item.template, @scroll_group_id)
    unless group
      warn { "Enchant item group for scroll #{id} does not exist." }
      return -1f64
    end

    group.get_chance(enchant_item.enchant_level)
  end

  def calculate_success(pc : L2PcInstance, enchant_item : L2ItemInstance?, support_item : EnchantSupportItem?) : EnchantResultType
    return EnchantResultType::ERROR unless valid?(enchant_item, support_item)
    chance = get_chance(pc, enchant_item)
    return EnchantResultType::ERROR if chance == -1
    bonus_rate = bonus_rate()
    support_bonus_rate = support_item.try &.bonus_rate || 0
    final_chance = Math.min(chance + bonus_rate + support_bonus_rate, 100)
    random = Rnd.rand * 100
    success = random < final_chance
    success ? EnchantResultType::SUCCESS : EnchantResultType::FAILURE
  end
end
