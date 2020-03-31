class Packets::Incoming::RequestDropItem < GameClientPacket
  no_action_request

  @id = 0
  @count = 0i64
  @x = 0
  @y = 0
  @z = 0

  private def read_impl
    @id = d
    @count = q
    @x = d
    @y = d
    @z = d
  end

  private def run_impl
    return unless pc = active_char
    return if pc.dead?

    unless flood_protectors.drop_item.try_perform_action("drop_item")
      return
    end

    unless item = pc.inventory.get_item_by_l2id(@id)
      debug { "Item with object id #{@id} not found in #{pc}'s inventory." }
      pc.send_packet(SystemMessageId::CANNOT_DISCARD_THIS_ITEM)
      return
    end

    if @count == 0 || !pc.validate_item_manipulation(@id, "drop") || (!Config.allow_discarditem && !pc.override_drop_all_items?) || (!item.droppable? && !(pc.override_drop_all_items? && Config.gm_trade_restricted_items)) || ((item.item_type == EtcItemType::PET_COLLAR) && pc.has_pet_items?) || pc.inside_no_item_drop_zone?
      debug { "Item with count #{@count} didn't pass validation." }
      pc.send_packet(SystemMessageId::CANNOT_DISCARD_THIS_ITEM)
      return
    end

    if item.quest_item? && !(pc.override_drop_all_items? && Config.gm_trade_restricted_items)
      debug { "Quest items can't be dropped." }
      return
    end

    if @count > item.count
      debug { "Can't drop #{@count}/#{item.count} items." }
      pc.send_packet(SystemMessageId::CANNOT_DISCARD_THIS_ITEM)
      return
    end

    if Config.player_spawn_protection > 0 && pc.invul? && !pc.gm?
      pc.send_packet(SystemMessageId::CANNOT_DISCARD_THIS_ITEM)
      return
    end

    if @count < 0
      Util.punish(pc, "tried to drop item with object id #{@id} with count < 0.")
      warn { "#{pc} attempted to drop #{item} x#{@count}." }
      return
    end

    if !item.stackable? && @count > 1
      Util.punish(pc, "tried to drop non_stackable item with object id #{@id} with count > 1.")
      warn { "#{pc} attempted to drop multiple non-stackable #{item}." }
      return
    end

    if Config.jail_disable_transaction && pc.jailed?
      pc.send_message("You cannot drop items in jail.")
      return
    end

    unless pc.access_level.allow_transaction?
      pc.send_message("Transactions are disaled for your access level.")
      pc.send_packet(SystemMessageId::NOTHING_HAPPENED)
      return
    end

    if pc.fishing?
      pc.send_packet(SystemMessageId::CANNOT_DO_WHILE_FISHING_2)
      return
    end

    return if pc.flying?

    if pc.casting_now?
      if pc.current_skill.try &.skill.item_consume_id.== item.id
        pc.send_packet(SystemMessageId::CANNOT_DISCARD_THIS_ITEM)
        return
      end
    end

    if pc.casting_simultaneously_now?
      if pc.last_simultaneous_skill_cast.try &.item_consume_id.== item.id
        pc.send_packet(SystemMessageId::CANNOT_DISCARD_THIS_ITEM)
        return
      end
    end

    if item.template.type_2 == ItemType2::QUEST && !pc.override_drop_all_items?
      debug { "#{pc} tried to drop a quest item." }
      pc.send_packet(SystemMessageId::CANNOT_DISCARD_EXCHANGE_ITEM)
      return
    end

    if !pc.inside_radius?(@x, @y, 0, 150, false, false) || (@z - pc.z).abs > 50
      debug { "#{pc} tried to drop an item too far away." }
      pc.send_packet(SystemMessageId::CANNOT_DISCARD_DISTANCE_TOO_FAR)
      return
    end

    unless pc.inventory.can_manipulate_with_item_id?(item.id)
      pc.send_message("You cannot use this item.")
      return
    end

    if item.equipped?
      unequipped = pc.inventory.unequip_item_in_slot_and_record(item.location_slot)

      iu = InventoryUpdate.new

      unequipped.each do |itm|
        itm.uncharge_all_shots
        iu.add_modified_item(itm)
      end

      pc.send_packet(iu)
      pc.broadcast_user_info
      pc.send_packet(ItemList.new(pc, true))
    end

    drop = pc.drop_item("Drop", @id, @count, @x, @y, @z, nil, false, false)

    debug { "Dropping #{drop} at #{@x} #{@y} #{@z}." }

    if drop && pc.gm?
      target = pc.target.try &.name
      GMAudit.log(pc, "Drop", target, "(id: #{drop.id}, name: #{drop.item_name}, obj_id: #{drop.l2id}, x: #{pc.x}, y: #{pc.y}, z: #{pc.z})")
    end

    if drop && drop.id == Inventory::ADENA_ID && drop.count >= 1_000_000
      msg = "#{pc} has dropped #{drop.count} adena at #{@x} #{@y} #{@z}."
      warn msg
      AdminData.broadcast_message_to_gms(msg)
    end
  end
end
