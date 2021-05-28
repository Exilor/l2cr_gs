require "./inventory"

class PcInventory < Inventory
  include Packets::Outgoing

  @quest_slots = 0
  @adena : L2ItemInstance?
  @ancient_adena : L2ItemInstance?

  getter owner
  getter block_mode = -1
  getter block_items : Array(Int32)? | Slice(Int32)?

  def initialize(owner : L2PcInstance)
    @owner = owner

    super()

    add_paperdoll_listener(ArmorSetListener)
    add_paperdoll_listener(BowCrossRodListener)
    add_paperdoll_listener(ItemSkillsListener)
    add_paperdoll_listener(BraceletListener)
  end

  def owner? : L2PcInstance
    owner
  end

  def base_location : ItemLocation
    ItemLocation::INVENTORY
  end

  def equip_location : ItemLocation
    ItemLocation::PAPERDOLL
  end

  def adena_instance : L2ItemInstance?
    @adena
  end

  def adena : Int64
    @adena.try &.count || 0i64
  end

  def ancient_adena_instance : L2ItemInstance?
    @ancient_adena
  end

  def ancient_adena : Int64
    @ancient_adena.try &.count || 0i64
  end

  def get_unique_items(adena : Bool, a_adena : Bool, avail : Bool = true) : Array(L2ItemInstance)
    list = [] of L2ItemInstance

    @items.each do |item|
      next if !adena && item.id == ADENA_ID
      next if !a_adena && item.id == ANCIENT_ADENA_ID
      duplicate = list.any? { |it| it.id == item.id }
      if !duplicate && (!avail || (item.sellable? && item.available?(@owner, false, false)))
        list << item
      end
    end

    list
  end

  def get_unique_items_by_enchant_level(adena : Bool, a_adena : Bool, avail : Bool = true) : Array(L2ItemInstance)
    list = [] of L2ItemInstance

    @items.each do |item|
      next if !adena && item.id == ADENA_ID
      next if !a_adena && item.id == ANCIENT_ADENA_ID
      duplicate = list.any? { |it| it.id == item.id && it.enchant_level == item.enchant_level }
      if !duplicate && (!avail || (item.sellable? && item.available?(@owner, false, false)))
        list << item
      end
    end

    list
  end

  def get_all_items_by_item_id(item_id : Int32) : Array(L2ItemInstance)
    get_all_items_by_item_id(item_id, true)
  end

  def get_all_items_by_item_id(item_id : Int32, include_equipped : Bool) : Array(L2ItemInstance)
    @items.select { |i| i.id == item_id && (include_equipped || !i.equipped?) }
  end

  def get_all_items_by_item_id(item_id : Int32, enchant : Int32) : Array(L2ItemInstance)
    get_all_items_by_item_id(item_id, enchant, true)
  end

  def get_all_items_by_item_id(item_id : Int32, enchant : Int32, include_equipped : Bool) : Array(L2ItemInstance)
    @items.select do |item|
      item.id == item_id &&
        item.enchant_level == enchant &&
        (include_equipped || !item.equipped?)
    end
  end

  def get_available_items(trade_list : TradeList) : Array(TradeItem)
    list = [] of TradeItem
    @items.each do |item|
      if item.available?(@owner, false, false)
        if adj_item = trade_list.adjust_available_item(item)
          list << adj_item
        end
      end
    end
    list
  end

  def get_available_items(adena : Bool, allow_non_tradeable : Bool, freightable : Bool) : Array(L2ItemInstance)
    @items.select do |item|
      case
      when !item.available?(@owner, adena, allow_non_tradeable)
        false
      when !can_manipulate_with_item_id?(item.id)
        false
      when freightable
        item.item_location.inventory? && item.freightable?
      else
        true
      end
    end
  end

  def augmented_items : Array(L2ItemInstance)
    @items.select &.augmented?
  end

  def element_items : Array(L2ItemInstance)
    @items.select &.elementals
  end

  def adjust_available_item(item : TradeItem)
    not_all_equipped = false
    get_items_by_item_id(item.item.id).each do |adj_item|
      if adj_item.equippable?
        unless adj_item.equipped?
          not_all_equipped |= true
        end
      else
        not_all_equipped |= true
        break
      end
    end

    if not_all_equipped
      adj_item = get_item_by_item_id(item.item.id).not_nil!
      item.l2id = adj_item.l2id
      item.enchant = adj_item.enchant_level
      if adj_item.count < item.count
        item.count = adj_item.count
      end

      return
    end

    item.count = 0
  end

  def add_adena(process : String?, count : Int64, actor : L2PcInstance, reference)
    if count > 0
      add_item(process, ADENA_ID, count, actor, reference)
    end
  end

  def reduce_adena(process : String?, count : Int64, actor : L2PcInstance, ref) : Bool
    if count > 0
      return !!destroy_item_by_item_id(process, ADENA_ID, count, actor, ref)
    end

    false
  end

  def add_ancient_adena(process : String?, count : Int64, actor : L2PcInstance, reference)
    if count > 0
      add_item(process, ANCIENT_ADENA_ID, count, actor, reference)
    end
  end

  def reduce_ancient_adena(process : String?, count : Int64, actor : L2PcInstance, reference) : Bool
    if count > 0
      return !!destroy_item_by_item_id(process, ANCIENT_ADENA_ID, count, actor, reference)
    end

    false
  end

  def add_item(item : L2ItemInstance)
    if item.quest_item?
      sync { @quest_slots += 1 }
    end

    super
  end

  def add_item(process : String?, item : L2ItemInstance, actor : L2PcInstance?, reference) : L2ItemInstance?
    item = super

    if item
      if item.id == ADENA_ID && item != @adena
        @adena = item
      elsif item.id == ANCIENT_ADENA_ID && item != @ancient_adena
        @ancient_adena = item
      end
    end

    if item && actor
      OnPlayerItemAdd.new(actor, item).async(actor, item.template)
    end

    item
  end

  def add_item(process : String?, item_id : Int32, count : Int64, enchant_level : Int32, actor : L2PcInstance, reference) : L2ItemInstance?
    return unless item = super

    if item.id == ADENA_ID && item != @adena
      @adena = item
    elsif item.id == ANCIENT_ADENA_ID && item != @ancient_adena
      @ancient_adena = item
    end

    if actor
      if Config.force_inventory_update
        actor.send_packet(ItemList.new(actor, false))
      else
        actor.send_packet(InventoryUpdate.single(item))
      end

      actor.send_packet(StatusUpdate.current_load(actor))

      OnPlayerItemAdd.new(actor, item).async(actor, item.template)
    end

    item
  end

  def transfer_item(process : String?, id : Int32, count : Int64, target : ItemContainer?, actor : L2PcInstance, reference) : L2ItemInstance?
    item = super

    if (a = @adena) && (a.count <= 0 || a.owner_id != owner_id)
      @adena = nil
    end

    if (aa = @ancient_adena) && (aa.count <= 0 || aa.owner_id != owner_id)
      @ancient_adena = nil
    end

    if item
      OnPlayerItemTransfer.new(actor, item, target).async(item.template)
    end

    item
  end

  def destroy_item(process : String?, item : L2ItemInstance, actor : L2PcInstance?, reference) : L2ItemInstance?
    destroy_item(process, item, item.count, actor, reference)
  end

  def destroy_item(process : String?, l2id : Int32, count : Int64, actor : L2PcInstance?, reference) : L2ItemInstance?
    return unless item = get_item_by_l2id(l2id)
    destroy_item(process, item, count, actor, reference)
  end

  def destroy_item(process : String?, item : L2ItemInstance, count : Int64, actor : L2PcInstance?, reference) : L2ItemInstance?
    item = super


    if (a = @adena) && a.count <= 0
      @adena = nil
    end

    if (aa = @ancient_adena) && aa.count <= 0
      @ancient_adena = nil
    end

    if item
      OnPlayerItemDestroy.new(actor, item).async(item.template)
    end

    item
  end

  def destroy_item_by_item_id(process : String?, id : Int32, count : Int64, actor : L2PcInstance, reference) : L2ItemInstance?
    return unless item = get_item_by_item_id(id)
    destroy_item(process, item, count, actor, reference)
  end

  def drop_item(process : String?, item : L2ItemInstance, actor : L2PcInstance, reference) : L2ItemInstance?
    item = super

    if (a = @adena) && (a.count <= 0 || a.owner_id != owner_id)
      @adena = nil
    end

    if (aa = @ancient_adena) && (aa.count <= 0 || aa.owner_id != owner_id)
      @ancient_adena = nil
    end

    if item
      OnPlayerItemDrop.new(actor, item, item.location).async
    end

    item
  end

  def drop_item(process : String?, id : Int32, count : Int64, actor : L2PcInstance, reference) : L2ItemInstance?
    item = super

    if (a = @adena) && (a.count <= 0 || a.owner_id != owner_id)
      @adena = nil
    end

    if (aa = @ancient_adena) && (aa.count <= 0 || aa.owner_id != owner_id)
      @ancient_adena = nil
    end

    if item
      OnPlayerItemDrop.new(actor, item, item.location).async
    end

    item
  end

  def remove_item(item : L2ItemInstance) : Bool
    owner.remove_item_from_shortcut(item.l2id)

    if item.l2id == owner.active_enchant_item_id
      owner.active_enchant_item_id = L2PcInstance::ID_NONE
    end

    if item.id == ADENA_ID
      @adena = nil
    elsif item.id == ANCIENT_ADENA_ID
      @ancient_adena = nil
    end

    if item.quest_item?
      sync do
        @quest_slots &-= 1
        if @quest_slots < 0
          @quest_slots = 0
          warn "Quest inventory size < 0!"
        end
      end
    end

    super
  end

  def refresh_weight
    super
    owner.refresh_overloaded
  end

  def restore
    super

    @adena = get_item_by_item_id(ADENA_ID)
    @ancient_adena = get_item_by_item_id(ANCIENT_ADENA_ID)
  end

  def self.restore_visible_inventory(id : Int32) : Slice(Slice(Int32))
    paperdoll = Slice.new(31) { Slice.new(3, 0) }

    sql = "SELECT object_id,item_id,loc_data,enchant_level FROM items WHERE owner_id=? AND loc='PAPERDOLL'"
    GameDB.each(sql, id) do |rs|
      slot = rs.get_i32(:"loc_data")
      paperdoll[slot][0] = rs.get_i32(:"object_id")
      paperdoll[slot][1] = rs.get_i32(:"item_id")
      paperdoll[slot][2] = rs.get_i32(:"enchant_level")
    end

    paperdoll
  end

  def check_inventory_slots_and_weight(item_list : Enumerable(L2Item), send_msg : Bool, send_skill_msg : Bool) : Bool
    loot_weight = 0
    required_slots = 0

    item_list.each do |item|
      if !item.stackable? || get_inventory_item_count(item.id, -1) <= 0
        required_slots &+= 1
      end
      loot_weight += item.weight
    end

    result = validate_capacity(required_slots) && validate_weight(loot_weight)
    if !result && send_msg
      owner.send_packet(SystemMessageId::SLOTS_FULL)
      if send_skill_msg
        owner.send_packet(SystemMessageId::WEIGHT_EXCEEDED_SKILL_UNAVAILABLE)
      end
    end

    result
  end

  def validate_capacity(item : L2ItemInstance) : Bool
    if item.template.has_ex_immediate_effect?
      return true
    end

    if item.stackable? && get_inventory_item_count(item.id, -1) > 0
      return true
    end

    validate_capacity(1, item.quest_item?)
  end

  def validate_capacity_by_item_id(id : Int32) : Bool
    item = get_item_by_item_id(id)
    if item.nil? || !(item.stackable? && get_inventory_item_count(id, -1) > 0)
      return validate_capacity(1, ItemTable[id].quest_item?)
    end

    true
  end

  def validate_capacity(slots : Int, quest_item : Bool = false) : Bool
    unless quest_item
      return @items.size - @quest_slots + slots <= owner.inventory_limit
    end

    @quest_slots + slots <= owner.quest_inventory_limit
  end

  def validate_weight(weight : Int) : Bool
    if owner.gm? && owner.diet_mode? && owner.access_level.allow_transaction?
      return true
    end

    @total_weight + weight <= owner.max_load
  end

  def set_inventory_block(block_items : Array(Int32), block_mode : Int32)
    @block_items = block_items
    @block_mode = block_mode
    owner.send_packet(ItemList.new(owner, false))
  end

  def unblock
    @block_mode = -1
    @block_items = nil
    owner.send_packet(ItemList.new(owner, false))
  end

  def has_inventory_block? : Bool
    return false unless items = @block_items
    @block_mode > -1 && items.size > 0
  end

  def block_all_items
    set_inventory_block(Array.new(ItemTable.array_size &+ 2, 0), 1)
  end

  def can_manipulate_with_item_id?(id : Int32) : Bool
    return true unless b = @block_items
    !(@block_mode == 0 && b.includes?(id) || @block_mode == 1 && !b.includes?(id))
  end

  def get_size(quest : Bool) : Int32
    quest ? @quest_slots : size &- @quest_slots
  end

  def apply_item_skills
    @items.each do |item|
      item.give_skills_to_owner
      item.apply_enchant_stats
    end
  end
end
