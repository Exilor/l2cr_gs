class Packets::Incoming::RequestPackageSend < GameClientPacket
  private BATCH_LENGTH = 12

  private record Item, id : Int32, count : Int64

  @l2id = 0
  @items : Slice(Item)?

  private def read_impl
    @l2id = d
    count = d
    if count <= 0 || count > Config.max_item_in_packet
      return
    end
    if count * BATCH_LENGTH != buffer.remaining
      return
    end

    items = Slice.new(count) do
      id = d
      cnt = q
      if id < 1 || cnt < 0
        return
      end
      Item.new(id, cnt)
    end

    @items = items
  end

  private def run_impl
    return unless _items = @items
    return unless pc = active_char
    unless pc.account_chars.has_key?(@l2id)
      return
    end

    unless flood_protectors.transaction.try_perform_action("deposit")
      pc.send_message("You depositing items too fast.")
      return
    end

    return unless manager = pc.last_folk_npc

    unless pc.inside_radius?(manager, L2Npc::INTERACTION_DISTANCE, false, false)
      return
    end

    if pc.active_enchant_item_id != L2PcInstance::ID_NONE
      Util.punish(pc, "tried to use freight while enchanting.")
      return
    end

    if Config.alt_game_karma_player_can_use_warehouse && pc.karma > 0
      return
    end

    fee = _items.size * Config.alt_freight_price
    current_adena = pc.adena
    slots = 0

    warehouse = PcFreight.new(@l2id)

    _items.each do |i|
      item = pc.check_item_manipulation(i.id, i.count, "freight")
      if item.nil?
        warn { "Error depositing a warehouse object for player #{pc}." }
        warehouse.delete_me
        return
      elsif item.freightable?
        warehouse.delete_me
        return
      end

      if item.id == Inventory::ADENA_ID
        current_adena -= i.count
      elsif !item.stackable?
        slots += i.count
      elsif warehouse.get_item_by_item_id(item.id).nil?
        slots += 1
      end
    end

    unless warehouse.validate_capacity(slots)
      pc.send_packet(SystemMessageId::YOU_HAVE_EXCEEDED_QUANTITY_THAT_CAN_BE_INPUTTED)
      warehouse.delete_me
      return
    end

    if current_adena < fee || !pc.reduce_adena(warehouse.name, fee, manager, false)
      pc.send_packet(SystemMessageId::YOU_NOT_ENOUGH_ADENA)
      warehouse.delete_me
      return
    end

    iu = InventoryUpdate.new unless Config.force_inventory_update

    _items.each do |i|
      unless old_item = pc.check_item_manipulation(i.id, i.count, "deposit")
        warn { "Error depositing to freight for player #{pc} (old_item is nil)." }
        warehouse.delete_me
        return
      end

      new_item = pc.inventory.transfer_item("trade", i.id, i.count, warehouse, pc, nil)
      unless new_item
        warn { "Error depositing to freight for player #{pc} (new_item is nil)." }
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

    warehouse.delete_me

    send_packet(iu || ItemList.new(pc, false))
    send_packet(StatusUpdate.current_load(pc))
  end
end
