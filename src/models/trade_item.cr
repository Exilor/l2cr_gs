class TradeItem
  @element_def_attr = {0, 0, 0, 0, 0, 0}

  getter item : L2Item
  getter location_slot = 0
  getter custom_type_1 = 0
  getter custom_type_2 = 0
  getter store_count = 0i64
  property l2id : Int32 = 0
  property enchant : Int32 = 0
  property count : Int64 = 1i64
  property price : Int64 = 0i64
  property attack_element_type : Int8 = Elementals::NONE
  property attack_element_power : Int32 = 0
  property enchant_options : Slice(Int32) = L2ItemInstance::DEFAULT_ENCHANT_OPTIONS

  def initialize(item : L2Item | L2ItemInstance | TradeItem, count : Int64, price : Int64)
    @count = count
    @price = price
    @store_count = count
    initialize(item)
  end

  private initializer item : L2Item

  def initialize(item : L2ItemInstance)
    @l2id = item.l2id
    @item = item.template
    @location_slot = item.location_slot
    @enchant = item.enchant_level
    @custom_type_1 = item.custom_type_1
    @custom_type_2 = item.custom_type_2
    @attack_element_type = item.attack_element_type
    @attack_element_power = item.attack_element_power
    @element_def_attr = {
      item.get_element_def_attr(0),
      item.get_element_def_attr(1),
      item.get_element_def_attr(2),
      item.get_element_def_attr(3),
      item.get_element_def_attr(4),
      item.get_element_def_attr(5)
    }
    @enchant_options = item.enchant_options
  end

  def initialize(item : TradeItem)
    @l2id = item.l2id
    @item = item.item
    @location_slot = item.location_slot
    @custom_type_1 = item.custom_type_1
    @custom_type_2 = item.custom_type_2
    @attack_element_type = item.attack_element_type
    @attack_element_power = item.attack_element_power
    @enchant_options = item.enchant_options
    @element_def_attr = {
      item.get_element_def_attr(0),
      item.get_element_def_attr(1),
      item.get_element_def_attr(2),
      item.get_element_def_attr(3),
      item.get_element_def_attr(4),
      item.get_element_def_attr(5)
    }
  end

  def get_element_def_attr(i : Int) : Int32
    @element_def_attr[i]
  end
end
