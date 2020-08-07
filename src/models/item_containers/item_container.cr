require "../items/instance/l2_item_instance"

abstract class ItemContainer
  include Synchronizable
  include Loggable

  getter items = Concurrent::Array(L2ItemInstance).new

  delegate size, to: @items

  abstract def owner? : L2Character?
  abstract def base_location : ItemLocation

  def name : String
    "ItemContainer"
  end

  def owner : L2Character
    owner?.not_nil!
  end

  def owner_id : Int32
    owner?.try &.l2id || 0
  end

  def get_item_by_item_id(id : Int32) : L2ItemInstance?
    @items.find { |item| item.id == id }
  end

  def get_item_by_item_id(id : Int32, item_to_ignore : L2ItemInstance) : L2ItemInstance?
    @items.find { |item| item.id == id && item != item_to_ignore }
  end

  def get_items_by_item_id(id : Int32) : Array(L2ItemInstance)
    @items.select { |item| item.id == id }
  end

  def get_item_by_l2id(id : Int32) : L2ItemInstance?
    @items.find { |item| item.l2id == id }
  end

  def get_inventory_item_count(item_id : Int32, enchant_level : Int32) : Int64
    get_inventory_item_count(item_id, enchant_level, true)
  end

  def get_inventory_item_count(item_id : Int32, enchant_level : Int32, include_equipped : Bool) : Int64
    count = 0i64

    @items.each do |item|
      if item.id == item_id
        if item.enchant_level == enchant_level || enchant_level < 0
          if include_equipped || !item.equipped?
            count += (item.stackable? ? item.count : 1)
          end
        end
      end
    end

    count
  end

  def add_item(item : L2ItemInstance)
    @items << item
  end

  def add_item(process : String?, item : L2ItemInstance, actor : L2PcInstance?, reference) : L2ItemInstance?
    old_item = get_item_by_item_id(item.id)

    if old_item && item.stackable?
      count = item.count
      old_item.change_count(process, count, actor, reference)
      old_item.last_change = L2ItemInstance::MODIFIED

      ItemTable.destroy_item(process, item, actor, reference)
      item.update_database
      item = old_item

      if item.id == Inventory::ADENA_ID && count < 10_000 * Config.rate_drop_amount_multiplier.fetch(Inventory::ADENA_ID, 1.0)
        if GameTimer.ticks % 5 == 0
          item.update_database
        end
      else
        item.update_database
      end
    else
      item.set_owner_id(process, owner_id, actor, reference)
      item.item_location = base_location
      item.last_change = L2ItemInstance::ADDED

      add_item(item)

      item.update_database
    end

    refresh_weight

    item
  end

  def add_item(process : String?, item_id : Int32, actor : L2PcInstance?, reference) : L2ItemInstance?
    add_item(process, item_id, 1, -1, actor, reference)
  end

  def add_item(process : String?, item_id : Int32, count : Int64, actor : L2PcInstance?, reference) : L2ItemInstance?
    add_item(process, item_id, count, -1, actor, reference)
  end

  def add_item(process : String?, item_id : Int32, count : Int64, enchant_level : Int32, actor : L2PcInstance?, reference) : L2ItemInstance?
    item = get_item_by_item_id(item_id)

    if item && item.stackable?
      item.change_count(process, count, actor, reference)
      item.last_change = L2ItemInstance::MODIFIED

      if item_id == Inventory::ADENA_ID && count < 10_000 * Config.rate_drop_amount_multiplier.fetch(Inventory::ADENA_ID, 1.0)
        if GameTimer.ticks % 5 == 0
          item.update_database
        end
      else
        item.update_database
      end
    else
      count.times do |i|
        unless template = ItemTable[item_id]?
          raise "ItemContainer#add_item: invalid item id #{item_id}"
        end

        actual_count = template.stackable? ? count : 1i64
        item = ItemTable.create_item(process, item_id, actual_count, actor, reference)
        item.owner_id = owner_id
        item.item_location = base_location
        item.last_change = L2ItemInstance::ADDED
        if enchant_level > -1
          item.enchant_level = enchant_level
        else
          item.enchant_level = template.default_enchant_level
        end

        add_item(item)

        item.update_database

        break if template.stackable? || !Config.multiple_item_drop
      end
    end

    refresh_weight

    item
  end

  def transfer_item(process : String?, l2id : Int32, count : Int64, target : ItemContainer?, actor : L2PcInstance?, reference) : L2ItemInstance?
    unless target
      debug "No target ItemContainer."
      return
    end
    unless source_item = get_item_by_l2id(l2id)
      debug { "Item with id #{l2id} not found." }
      return
    end

    if source_item.stackable?
      target_item = target.get_item_by_item_id(source_item.id)
    end

    source_item.sync do
      if get_item_by_l2id(l2id) != source_item
        debug { "get_item_by_l2id(#{l2id}) != #{source_item}" }
        return
      end

      count = source_item.count if count > source_item.count

      if source_item.count == count && target_item.nil?
        remove_item(source_item)
        target.add_item(process, source_item, actor, reference)
        target_item = source_item
      else
        if source_item.count > count
          source_item.change_count(process, -count, actor, reference)
        else
          remove_item(source_item)
          ItemTable.destroy_item(process, source_item, actor, reference)
        end

        if target_item
          target_item.change_count(process, count, actor, reference)
        else
          target_item = target.add_item(process, source_item.id, count, actor, reference)
        end
      end

      source_item.update_database(true)

      if target_item != source_item && target_item
        target_item.update_database
      end

      if (aug = source_item.augmentation) && actor # actor check is custom
        aug.remove_bonus(actor)
      end

      refresh_weight
      target.refresh_weight
    end

    target_item
  end

  def destroy_item(process : String?, item : L2ItemInstance, actor : L2PcInstance?, reference) : L2ItemInstance?
    destroy_item(process, item, item.count, actor, reference)
  end

  def destroy_item(process : String?, item : L2ItemInstance, count : Int64, actor : L2PcInstance?, reference) : L2ItemInstance?
    item.sync do
      if item.count > count
        item.change_count(process, -count, actor, reference)
        item.last_change = L2ItemInstance::MODIFIED

        if process || GameTimer.ticks % 10 == 0
          item.update_database
        end

        refresh_weight
      else
        return if item.count < count

        return unless remove_item(item)

        ItemTable.destroy_item(process, item, actor, reference)

        item.update_database
        refresh_weight
      end

      item.delete_me
    end

    item
  end

  def destroy_item(process : String?, l2id : Int32, count : Int64, actor : L2PcInstance?, reference) : L2ItemInstance?
    if item = get_item_by_l2id(l2id)
      destroy_item(process, item, count, actor, reference)
    end
  end

  def destroy_item_by_item_id(process : String?, item_id : Int32, count : Int64, actor : L2PcInstance?, reference) : L2ItemInstance?
    if item = get_item_by_item_id(item_id)
      destroy_item(process, item, count, actor, reference)
    end
  end

  def destroy_all_items(process : String?, actor : L2PcInstance?, reference)
    @items.safe_each do |item|
      destroy_item(process, item, item.count, actor, reference)
    end
  end

  def adena : Int64
    if adena = @items.find { |item| item.id == Inventory::ADENA_ID }
      return adena.count
    end

    0i64
  end

  def remove_item(item : L2ItemInstance) : Bool
    !!@items.delete_first(item)
  end

  def refresh_weight
    # no-op
  end

  def delete_me
    if owner?
      @items.each do |item|
        item.update_database(true)
        item.delete_me
        L2World.remove_object(item)
      end
    end

    @items.clear
  end

  def update_database
    if owner?
      @items.each &.update_database(true)
    end
  end

  def restore
    sql = "SELECT object_id, item_id, count, enchant_level, loc, loc_data, custom_type1, custom_type2, mana_left, time FROM items WHERE owner_id=? AND (loc=?)"
    GameDB.each(sql, owner_id, base_location.to_s) do |rs|
      unless item = L2ItemInstance.restore_from_db(owner_id, rs)
        next
      end

      L2World.store_object(item)

      owner = owner?.try &.acting_player

      if item.stackable? && get_item_by_item_id(item.id)
        add_item("Restore", item, owner, nil)
      else
        add_item(item)
      end
    end

    refresh_weight
  rescue e
    error e
  end

  def validate_capacity(slots : Int) : Bool
    true
  end

  def validate_weight(weight : Int) : Bool
    true
  end

  def validate_capacity_by_item_id(id : Int, count : Int) : Bool
    t = ItemTable[id]?
    t.nil? || (t.stackable? ? validate_capacity(1) : validate_capacity(count))
  end

  def validate_weight_by_item_id(id : Int, count : Int) : Bool
    t = ItemTable[id]?
    t.nil? || validate_weight(t.weight * count)
  end

  def has_item_for_self_resurrection? : Bool
    @items.any? &.template.allows_self_resurrection?
  end
end
