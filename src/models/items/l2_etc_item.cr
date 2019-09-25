require "./l2_item"
require "../../enums/etc_item_type"
require "../item_containers/inventory"
require "../l2_extractable_product"

class L2EtcItem < L2Item
  getter item_type : EtcItemType
  getter handler_name : String?
  getter extractable_items : Slice(L2ExtractableProduct)?
  getter? blessed = false

  def initialize(set : StatsSet)
    super

    @item_type = set.get_enum("etcitem_type", EtcItemType, EtcItemType::NONE)

    case @default_action # ActionType
    when .soulshot?, .summon_soulshot?, .spiritshot?, .summon_spiritshot?
      @item_type = EtcItemType::SHOT
    end

    @type_1 = ItemType1::ITEM_QUESTITEM_ADENA
    @type_2 = ItemType2::OTHER

    if quest_item?
      @type_2 = ItemType2::QUEST
    elsif @item_id == Inventory::ADENA_ID || @item_id == Inventory::ANCIENT_ADENA_ID
      @type_2 = ItemType2::MONEY
    end

    @handler_name = set.get_string("handler", nil)
    @blessed = set.get_bool("blessed", false)

    if capsuled_items = set.get_string("capsuled_items", nil)
      extractable_items = nil
      capsuled_items.split(';') do |part|
        part = part.strip
        next if part.empty?

        data = part.split(',')
        if data.size != 4
          warn { "Capsuled item part has a size of #{data.size} but should by 4." }
          next
        end

        item_id = data.shift.to_i
        min = data.shift.to_i
        max = data.shift.to_i
        chance = data.shift.to_f

        if max < min
          warn { "Capsuled item max amount (#{max}) is smaller than min amount #{min}." }
          next
        end

        product = L2ExtractableProduct.new(item_id, min, max, chance)
        (extractable_items ||= [] of L2ExtractableProduct) << product
        unless @handler_name
          warn "Item defines capsuled items but not a handler."
          @handler_name = "ExtractableItems"
        end
      end

      if extractable_items && !extractable_items.empty?
        @extractable_items = extractable_items.to_slice!
      end
    end
  end

  def mask : UInt32
    0u32 # EtcItemType#mask is always 0
  end
end
