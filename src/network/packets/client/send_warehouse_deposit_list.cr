class Packets::Incoming::SendWarehouseDepositList < GameClientPacket
  BATCH_LENGTH = 12

  @items : Array(ItemHolder)?

  private def read_impl
    size = d

    if size <= 0 || size > Config.max_item_in_packet
      return
    elsif size * BATCH_LENGTH != buffer.remaining
      return
    end

    items = Array(ItemHolder).new(size)
    size.times do
      id = d
      if id < 1
        return
      end
      count = q
      if count < 0
        return
      end
      items << ItemHolder.new(id, count)
    end
    @items = items
  end

  private def run_impl
    return unless _items = @items
    return unless pc = active_char

    unless flood_protectors.transaction.try_perform_action("deposit")
      pc.send_message("You are depositing items too fast.")
      return
    end

    return unless warehouse = pc.active_warehouse

    is_private = warehouse.is_a?(PcWarehouse)

    manager = pc.last_folk_npc

    unless manager && manager.warehouse?
      return
    end

    if !manager.can_interact?(pc) && !pc.gm?
      return
    end

    if !is_private && !pc.access_level.allow_transaction?
      pc.send_message("Transactions are disabled for your Access Level.")
      return
    end

    if pc.active_enchant_item_id != L2PcInstance::ID_NONE
      Util.punish(pc, "tried to deposit items on a warehouse while enchanting.")
      return
    end

    if !Config.alt_game_karma_player_can_use_warehouse && pc.karma > 0
      return
    end

    fee = _items.size.to_i64 * 30
    current_adena = pc.adena
    slots = 0

    _items.each do |i|
      item = pc.check_item_manipulation(i.id, i.count, "deposit")
      unless item
        warn { "Error depositing a warehouse object for char #{pc} (validity check)." }
        return
      end

      if item.id == Inventory::ADENA_ID
        current_adena -= i.count
      end

      if !item.stackable?
        slots += i.count
      elsif warehouse.get_item_by_item_id(item.id).nil?
        slots += 1
      end
    end

    unless warehouse.validate_capacity(slots)
      pc.send_packet(SystemMessageId::YOU_HAVE_EXCEEDED_QUANTITY_THAT_CAN_BE_INPUTTED)
      return
    end

    if current_adena < fee || !pc.reduce_adena(warehouse.name, fee, manager, false)
      pc.send_packet(SystemMessageId::YOU_NOT_ENOUGH_ADENA)
      return
    end

    if pc.active_trade_list
      return
    end

    iu = InventoryUpdate.new if Config.force_inventory_update

    _items.each do |i|

      old_item = pc.check_item_manipulation(i.id, i.count, "deposit")
      unless old_item
        warn { "Error depositing a warehouse object for char #{pc} (validity check)." }
        return
      end

      if !old_item.depositable?(is_private) || !old_item.available?(pc, true, is_private)
        next
      end

      new_item = pc.inventory.transfer_item(warehouse.name, i.id, i.count, warehouse, pc, manager)

      unless new_item
        warn { "Error depositing a warehouse object for char #{pc} (newitem == null)." }
        next
      end

      if iu
        if old_item.count > 0 && old_item != new_item
          iu.add_modified_item(old_item)
        else
          iu.add_removed_item(old_item)
        end
      end
    end

    pc.send_packet(iu || ItemList.new(pc, false))
    pc.send_packet(StatusUpdate.current_load(pc))
  end
end
