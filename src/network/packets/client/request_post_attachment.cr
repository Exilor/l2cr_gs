class Packets::Incoming::RequestPostAttachment < GameClientPacket
  no_action_request

  @msg_id = 0

  def read_impl
    @msg_id = d
  end

  def run_impl
    return unless Config.allow_mail && Config.allow_attachments
    return unless pc = active_char

    unless flood_protectors.transaction.try_perform_action("getattach")
      debug "Flood detected."
      return
    end

    unless pc.access_level.allow_transaction?
      pc.send_message("Transactions are disabled for your Access Level")
      return
    end

    unless pc.inside_peace_zone?
      pc.send_packet(SystemMessageId::CANT_RECEIVE_NOT_IN_PEACE_ZONE)
      return
    end

    if pc.active_trade_list
      pc.send_packet(SystemMessageId::CANT_RECEIVE_DURING_EXCHANGE)
      return
    end

    if pc.enchanting?
      pc.send_packet(SystemMessageId::CANT_RECEIVE_DURING_ENCHANT)
      return
    end

    unless pc.private_store_type.none?
      pc.send_packet(SystemMessageId::CANT_RECEIVE_PRIVATE_STORE)
      return
    end

    unless msg = MailManager.get_message(@msg_id)
      warn "Message with ID #{@msg_id} not found."
      return
    end

    if msg.receiver_id != pc.l2id
      Util.punish(pc, "tried to receive mail attachments he doesn't own.")
    end

    unless msg.has_attachments?
      warn "Message with ID #{@msg_id} has no attachments."
      return
    end

    unless attachments = msg.attachments
      warn "Message with ID #{@msg_id} has attachments but its item container couldn't be found."
      return
    end

    weight = slots = 0

    debug "Taking #{attachments.items.size} attachments."

    attachments.items.each do |item|
      if item.owner_id != msg.sender_id
        Util.punish(pc, "tried to get items intended to someone else.")
        warn "#{pc.name} tried to receive a mailed item not owned by its sender (1)."
        return
      end

      unless item.item_location.mail?
        Util.punish(pc, "tried to get an item from mail which was not in the mail.")
        warn "#{item} should be in ItemLocation::MAIL but it's in #{item.item_location.inspect}."
        return
      end

      if item.location_slot != msg.id
        Util.punish(pc, "tried to get items from another mail attachment.")
        "#{pc.name} tried to receive a mailed item from a different attachment."
        return
      end

      weight += item.count * item.template.weight

      if !item.stackable?
        slots += item.count
      elsif pc.inventory.get_item_by_item_id(item.id).nil?
        slots += 1
      end
    end

    unless pc.inventory.validate_capacity(slots)
      pc.send_packet(SystemMessageId::CANT_RECEIVE_INVENTORY_FULL)
      return
    end

    unless pc.inventory.validate_weight(weight)
      pc.send_packet(SystemMessageId::CANT_RECEIVE_INVENTORY_FULL)
      return
    end

    adena = msg.req_adena

    if adena > 0 && !pc.reduce_adena("PayMail", adena, nil, true)
      pc.send_packet(SystemMessageId::CANT_RECEIVE_NO_ADENA)
      return
    end

    unless Config.force_inventory_update
      iu = InventoryUpdate.new
    end

    attachments.items.safe_each do |item|
      debug "Transferring #{item}."
      if item.owner_id != msg.sender_id
        Util.punish(pc, "tried to get items from a mail sent to somebody else.")
        warn "#{pc.name} tried to receive an item not owned by its sender (2)."
        return
      end

      count = item.count
      new_item = attachments.transfer_item(attachments.name, item.l2id, item.count, pc.inventory, pc, nil)
      unless new_item
        warn "Item transfer of #{item} failed."
        return
      end

      if iu
        if new_item.count > count
          iu.add_modified_item(new_item)
        else
          iu.add_new_item(new_item)
        end
      end

      sm = SystemMessage.you_acquired_s2_s1
      sm.add_item_name(item.id)
      sm.add_long(count)
      pc.send_packet(sm)
    end

    debug "Done transferring items."

    if iu
      pc.send_packet(iu)
    else
      pc.send_packet(ItemList.new(pc, false))
    end

    msg.remove_attachments
    pc.send_packet(StatusUpdate.current_load(pc))
    sender = L2World.get_player(msg.sender_id)

    if adena > 0
      if sender
        sender.add_adena("PayMail", adena, pc, false)
        sm = SystemMessage.payment_of_s1_adena_completed_by_s2
        sm.add_long(adena)
        sm.add_char_name(pc)
        sender.send_packet(sm)
      else
        paid_adena = ItemTable.create_item("PayMail", Inventory::ADENA_ID, adena, pc, nil)
        paid_adena.owner_id = msg.sender_id
        paid_adena.item_location = ItemLocation::INVENTORY
        paid_adena.update_database(true)
        L2World.remove_object(paid_adena)
      end
    elsif sender
      sm = SystemMessage.s1_acquired_attached_item
      sm.add_char_name(pc)
      sender.send_packet(sm)
    end

    pc.send_packet(ExChangePostState.new(true, @msg_id, Message::READ))
    pc.send_packet(SystemMessageId::MAIL_SUCCESSFULLY_RECEIVED)
  end
end
