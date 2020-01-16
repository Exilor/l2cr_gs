# class TradeItem
#   ELEM_DEF_ATTR = Int32.slice(0, 0, 0, 0, 0, 0)

#   getter item : L2Item
#   getter location_slot = 0
#   getter custom_type_1 = 0
#   getter custom_type_2 = 0
#   getter store_count = 0i64


#   property l2id : Int32 = 0
#   property enchant : Int32 = 0
#   property count : Int64 = 1i64
#   property price : Int64 = 0i64
#   property attack_element_type : Int8 = 0i8
#   property attack_element_power : Int32 = 0
#   property enchant_options : Slice(Int32) = Slice(Int32).empty
#   @element_def_attr = ELEM_DEF_ATTR

#   def initialize(item, count : Int64, price : Int64)
#     @count = count
#     @price = price
#     @l2id = 0
#     @location_slot = 0
#     @enchant = 0
#     @custom_type_1 = 0
#     @custom_type_2 = 0
#     @store_count = count
#     @attack_element_type = Elementals::NONE
#     @attack_element_power = 0
#     @enchant_options = L2ItemInstance::DEFAULT_ENCHANT_OPTIONS

#     initialize(item)
#   end

#   def initialize(item : L2ItemInstance)
#     @store_count = 0i64
#     @l2id = item.l2id
#     @item = item.template
#     @location_slot = item.location_slot
#     @enchant = item.enchant_level
#     @custom_type_1 = item.custom_type_1
#     @custom_type_2 = item.custom_type_2
#     @attack_element_type = item.attack_element_type
#     @attack_element_power = item.attack_element_power
#     @element_def_attr = Slice(Int32).new(6) { |i| item.get_element_def_attr(i) }
#     @enchant_options = item.enchant_options
#   end

#   def initialize(@item : L2Item)
#   end

#   def initialize(item : TradeItem)
#     @l2id = item.l2id
#     @item = item.item
#     @location_slot = item.location_slot
#     @custom_type_1 = item.custom_type_1
#     @custom_type_2 = item.custom_type_2
#     @attack_element_type = item.attack_element_type
#     @attack_element_power = item.attack_element_power
#     @enchant_options = item.enchant_options
#     @element_def_attr = Slice(Int32).new(6) { |i| item.get_element_def_attr(i) }
#   end

#   def get_element_def_attr(i : Int) : Int32
#     @element_def_attr[i]
#   end
# end



# class TradeItem
#   @element_def_attr = {0, 0, 0, 0, 0, 0}
#   getter item : L2Item
#   getter location_slot = 0
#   getter custom_type_1 = 0
#   getter custom_type_2 = 0
#   getter store_count = 0i64
#   property l2id : Int32 = 0
#   property enchant : Int32 = 0
#   property count : Int64 = 1i64
#   property price : Int64 = 0i64
#   property attack_element_type : Int8 = Elementals::NONE
#   property attack_element_power : Int32 = 0
#   property enchant_options : Slice(Int32) = L2ItemInstance::DEFAULT_ENCHANT_OPTIONS

#   def initialize(item : L2Item | L2ItemInstance | TradeItem, @count : Int64, @price : Int64)
#     @store_count = count
#     initialize(item)
#   end

#   private initializer item: L2Item

#   def initialize(item : L2ItemInstance)
#     @l2id = item.l2id
#     @item = item.template
#     @location_slot = item.location_slot
#     @enchant = item.enchant_level
#     @custom_type_1 = item.custom_type_1
#     @custom_type_2 = item.custom_type_2
#     @attack_element_type = item.attack_element_type
#     @attack_element_power = item.attack_element_power
#     @element_def_attr = {
#       item.get_element_def_attr(0),
#       item.get_element_def_attr(1),
#       item.get_element_def_attr(2),
#       item.get_element_def_attr(3),
#       item.get_element_def_attr(4),
#       item.get_element_def_attr(5)
#     }
#     @enchant_options = item.enchant_options
#   end

#   def initialize(item : TradeItem)
#     @l2id = item.l2id
#     @item = item.item
#     @location_slot = item.location_slot
#     @custom_type_1 = item.custom_type_1
#     @custom_type_2 = item.custom_type_2
#     @attack_element_type = item.attack_element_type
#     @attack_element_power = item.attack_element_power
#     @enchant_options = item.enchant_options
#     @element_def_attr = {
#       item.get_element_def_attr(0),
#       item.get_element_def_attr(1),
#       item.get_element_def_attr(2),
#       item.get_element_def_attr(3),
#       item.get_element_def_attr(4),
#       item.get_element_def_attr(5)
#     }
#   end

#   def get_element_def_attr(i : Int) : Int32
#     @element_def_attr[i]
#   end
# end

class TradeItem
  getter store_count = 0i64
  property l2id : Int32 = 0
  property enchant : Int32 = 0
  property count : Int64 = 1i64
  property price : Int64 = 0i64
  property attack_element_type : Int8 = Elementals::NONE
  property attack_element_power : Int32 = 0
  property enchant_options : Slice(Int32) = L2ItemInstance::DEFAULT_ENCHANT_OPTIONS

  def initialize(@item : L2Item | L2ItemInstance | TradeItem, @count : Int64, @price : Int64)
    @store_count = count
    initialize(item)
  end

  private initializer item : L2Item

  def initialize(@item : L2ItemInstance | TradeItem)
    @l2id = item.l2id
    @attack_element_type = item.attack_element_type
    @attack_element_power = item.attack_element_power
    @enchant_options = item.enchant_options
    if item.is_a?(L2ItemInstance)
      @enchant = item.enchant_level
    end
  end

  private macro switch(a, b, c)
    item = @item
    item.is_a?(L2ItemInstance) ? {{a}} : item.is_a?(TradeItem) ? {{b}} : {{c}}
  end

  def item : L2Item
    switch(item.template, item.item, item).as(L2Item)
  end

  def location_slot : Int32
    switch(item.location_slot, item.location_slot, 0)
  end

  def custom_type_1 : Int32
    switch(item.custom_type_1, item.custom_type_1, 0)
  end

  def custom_type_2 : Int32
    switch(item.custom_type_2, item.custom_type_2, 0)
  end

  def get_element_def_attr(i : Int) : Int32
    switch(item.get_element_def_attr(i), item.get_element_def_attr(i), 0)
  end
end
