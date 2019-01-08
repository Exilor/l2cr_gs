struct ItemInfo
  @elem_def_attr : Slice(Int32)
  @type_1 : Int32
  @type_2 : Int32
  getter l2id : Int32
  getter template : L2Item
  getter enchant : Int32
  getter augmentation_bonus = 0
  getter count : Int64
  getter equipped = 0
  getter change = 0
  getter mana = -1
  getter time = -9999
  getter location : Int32
  getter attack_element_type = -2
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
    if item.augmented?
      @augmentation_bonus = item.augmentation.augmentation_id
    end

    @count = item.count.to_i64
    @type_1 = item.custom_type_1
    @type_2 = item.custom_type_2
    @equipped = item.equipped? ? 1 : 0

    case item.last_change
    when L2ItemInstance::ADDED
      @change = 1
    when L2ItemInstance::MODIFIED
      @change = 2
    when L2ItemInstance::REMOVED
      @change = 3
    end

    @mana = item.mana
    @time = item.time_limited_item? ? (item.remaining_time / 1000).to_i : -9999
    @attack_element_type = item.attack_element_type.to_i32
    @attack_element_power = item.attack_element_power
    @elem_def_attr = Slice.new(6) { |i| item.get_element_def_attr(i) }
    @enchant_options = item.enchant_options
    @location = item.location_slot
  end

  def initialize(item : TradeItem)
    @l2id = item.l2id
    @template = item.item
    @enchant = item.enchant

    @count = item.count
    @type_1 = item.custom_type_1
    @type_2 = item.custom_type_2

    @attack_element_type = item.attack_element_type.to_i32
    @attack_element_power = item.attack_element_power
    @elem_def_attr = Slice.new(6) { |i| item.get_element_def_attr(i) }
    @enchant_options = item.enchant_options
    @location = item.location_slot
  end

  def get_element_def_attr(i : Int) : Int32
    @elem_def_attr[i]
  end

  def custom_type_1
    @type_1
  end

  def custom_type_2
    @type_2
  end
end
