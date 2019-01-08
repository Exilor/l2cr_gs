require "./item_container"

class Mail < ItemContainer
  getter_initializer owner_id: Int32, message_id: Int32

  def name
    "Mail"
  end

  def owner?
    # return nil
  end

  def base_location
    ItemLocation::MAIL
  end

  def message_id=(id)
    @message_id = id
    @items.each { |it| it.set_item_location(base_location, id) }
    update_database
  end

  def return_to_wh(wh)
    @items.each do |item|
      if wh
        transfer_item("Expire", item.l2id, item.count, wh, nil, nil)
      else
        item.item_location = ItemLocation::WAREHOUSE
      end
    end
  end

  def add_item(item : L2ItemInstance)
    super
    item.set_item_location(base_location, @message_id)
  end

  def update_database
    @items.each { |item| item.update_database(true) }
  end

  def restore
    sql = "SELECT object_id, item_id, count, enchant_level, loc, loc_data, custom_type1, custom_type2, mana_left, time FROM items WHERE owner_id=? AND loc=? AND loc_data=?"
    GameDB.each(sql, owner_id, base_location.to_s, message_id) do |rs|
      unless item = L2ItemInstance.restore_from_db(owner_id, rs)
        warn "An item wasn't restored."
        next
      end

      L2World.store_object(item)

      if item.stackable? && get_item_by_item_id(item.id)
        add_item("Restore", item, nil, nil)
      else
        add_item(item)
      end
    end
  rescue e
    error e
  end

  def delete_me
    @items.each do |item|
      item.update_database(true)
      item.delete_me
      L2World.remove_object(item)
      IdFactory.release(item.l2id)
    end
    @items.clear
  end
end
