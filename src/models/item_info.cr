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
    if item.augmented? && (aug = item.augmentation)
      @augmentation_bonus = aug.augmentation_id
    end

    @count = item.count.to_i64
    @custom_type_1 = item.custom_type_1
    @custom_type_2 = item.custom_type_2
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
    @time = item.time_limited_item? ? (item.remaining_time // 1000).to_i : -9999
    @attack_element_type = item.attack_element_type.to_i32
    @attack_element_power = item.attack_element_power
    @elem_def_attr = {
      item.get_element_def_attr(0),
      item.get_element_def_attr(1),
      item.get_element_def_attr(2),
      item.get_element_def_attr(3),
      item.get_element_def_attr(4),
      item.get_element_def_attr(5)
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

    @attack_element_type = item.attack_element_type.to_i32
    @attack_element_power = item.attack_element_power
    @elem_def_attr = {
      item.get_element_def_attr(0),
      item.get_element_def_attr(1),
      item.get_element_def_attr(2),
      item.get_element_def_attr(3),
      item.get_element_def_attr(4),
      item.get_element_def_attr(5)
    }
    @enchant_options = item.enchant_options
    @location = item.location_slot
  end

  def get_element_def_attr(i : Int) : Int32
    @elem_def_attr[i]
  end
end

# struct ItemInfo
#   initializer item : L2ItemInstance | TradeItem, change : Int32? = nil

#   delegate l2id, template, count, custom_type_1, custom_type_2, enchant_options,
#     get_element_def_attr, attack_element_type, attack_element_power, to: @item

#   private macro switch(a, b)
#     (i = @item).is_a?(L2ItemInstance) ? {{a}} : {{b}}
#   end

#   def template : L2Item
#     switch(i.template, i.item)
#   end

#   def enchant : Int32
#     switch(i.enchant_level, i.enchant)
#   end

#   def augmentation_bonus : Int32
#     switch((aug = i.augmentation) ? aug.augmentation_id : 0, 0)
#   end

#   def equipped : Int32
#     switch(i.equipped? ? 1 : 0, 0)
#   end

#   def change : Int32
#     switch(get_last_change(i), 0)
#   end

#   private def get_last_change(item)
#     @change ||
#     case item.last_change
#     when L2ItemInstance::ADDED
#       1
#     when L2ItemInstance::MODIFIED
#       2
#     else
#       3
#     end
#   end

#   def mana : Int32
#     switch(i.mana, -1)
#   end

#   def time : Int32
#     switch(i.time_limited_item? ? (i.remaining_time / 1000).to_i : -9999, -9999)
#   end

#   def location : Int32
#     @item.location_slot
#   end
# end
