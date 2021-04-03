struct ItemInfo
  @elem_def_attr : {Int32, Int32, Int32, Int32, Int32, Int32}

  getter l2id : Int32
  getter template : L2Item
  getter enchant : Int32
  getter custom_type_1 : Int32
  getter custom_type_2 : Int32
  getter augmentation_bonus = 0
  getter count : Int64
  getter equipped = 0
  getter change = 0
  getter mana = -1
  getter time = -9999
  getter location : Int32
  getter attack_element_type = -2i8
  getter attack_element_power = 0
  getter enchant_options : Slice(Int32)

  def initialize(item : L2ItemInstance, change : Int32)
    initialize(item)
    @change = change
  end

  def initialize(item : L2ItemInstance)
    @l2id = item.l2id
    @template = item.template
    @enchant = item.enchant_level
    if item.augmented? && (aug = item.augmentation)
      @augmentation_bonus = aug.augmentation_id
    end

    @count = item.count
    @custom_type_1 = item.custom_type_1
    @custom_type_2 = item.custom_type_2
    @equipped = item.equipped? ? 1 : 0

    if item.last_change > 0
      @change = item.last_change
    end

    @mana = item.mana
    @time = item.time_limited_item? ? (item.remaining_time // 1000).to_i : -9999
    @attack_element_type = item.attack_element_type
    @attack_element_power = item.attack_element_power
    @elem_def_attr = {
      item.get_element_def_attr(0), item.get_element_def_attr(1),
      item.get_element_def_attr(2), item.get_element_def_attr(3),
      item.get_element_def_attr(4), item.get_element_def_attr(5)
    }
    @enchant_options = item.enchant_options
    @location = item.location_slot
  end

  def initialize(item : TradeItem)
    @l2id = item.l2id
    @template = item.item
    @enchant = item.enchant

    @count = item.count
    @custom_type_1 = item.custom_type_1
    @custom_type_2 = item.custom_type_2

    @attack_element_type = item.attack_element_type
    @attack_element_power = item.attack_element_power
    @elem_def_attr = {
      item.get_element_def_attr(0), item.get_element_def_attr(1),
      item.get_element_def_attr(2), item.get_element_def_attr(3),
      item.get_element_def_attr(4), item.get_element_def_attr(5)
    }
    @enchant_options = item.enchant_options
    @location = item.location_slot
  end

  def get_element_def_attr(i : Int) : Int32
    @elem_def_attr[i]
  end
end
