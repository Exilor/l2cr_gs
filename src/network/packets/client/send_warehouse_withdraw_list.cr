class Packets::Incoming::SendWarehouseWithdrawList < GameClientPacket
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

    unless flood_protectors.transaction.try_perform_action("withdraw")
      pc.send_message("You are withdrawing items too fast.")
      return
    end

    return unless warehouse = pc.active_warehouse

    return unless manager = pc.last_folk_npc
    return unless manager.warehouse?
    unless pc.access_level.allow_transaction?
      pc.send_message("Transactions are disabled for your access level.")
      return
    end

    if !Config.alt_game_karma_player_can_use_warehouse && pc.karma > 0
      return
    end

    if Config.alt_members_can_withdraw_from_clanwh
      if warehouse.is_a?(ClanWarehouse) && !pc.has_clan_privilege?(ClanPrivilege::CL_VIEW_WAREHOUSE)
        return
      end
    else
      if warehouse.is_a?(ClanWarehouse) && !pc.clan_leader?
        pc.send_packet(SystemMessageId::ONLY_CLAN_LEADER_CAN_RETRIEVE_ITEMS_FROM_CLAN_WAREHOUSE)
        return
      end
    end

    weight = slots = 0

    _items.each do |i|
      item = warehouse.get_item_by_l2id(i.id)
      if item.nil? || item.count < i.count
        Util.punish(pc, "tried to withdraw an item from a warehouse without that item being there.")
        return
      end

      weight += i.count * item.template.weight
      if !item.stackable?
        slots += i.count
      elsif pc.inventory.get_item_by_item_id(item.id).nil?
        slots += 1
      end
    end

    unless pc.inventory.validate_capacity(slots)
      pc.send_packet(SystemMessageId::SLOTS_FULL)
      return
    end

    unless pc.inventory.validate_weight(weight)
      pc.send_packet(SystemMessageId::WEIGHT_LIMIT_EXCEEDED)
      return
    end

    if Config.force_inventory_update
      iu = InventoryUpdate.new
    end

    _items.each do |i|
      old_item = warehouse.get_item_by_l2id(i.id) # shouldn't this be by_item_id ?
      if old_item.nil? || old_item.count < i.count
        warn { "Error withdrawing a warehouse object for char #{pc} (old_item == nil)." }
        return
      end
      new_item = warehouse.transfer_item(warehouse.name, i.id, i.count, pc.inventory, pc, manager)
      unless new_item
        warn { "Error withdrawing a warehouse object for char #{pc} (new_item == nil)." }
        return
      end

      if iu
        if new_item.count > i.count
          iu.add_modified_item(new_item)
        else
          iu.add_new_item(new_item)
        end
      end
    end

    pc.send_packet(iu || ItemList.new(pc, false))
    pc.send_packet(StatusUpdate.current_load(pc))
  end
end
