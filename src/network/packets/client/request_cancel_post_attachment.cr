class Packets::Incoming::RequestCancelPostAttachment < GameClientPacket
  no_action_request

  @msg_id = 0

  private def read_impl
    @msg_id = d
  end

  private def run_impl
    return unless pc = active_char
    return unless Config.allow_mail
    return unless Config.allow_attachments

    unless flood_protectors.transaction.try_perform_action("cancelpost")
      return
    end

    unless msg = MailManager.get_message(@msg_id)
      warn { "Message with id #{@msg_id} not found." }
      return
    end

    if msg.sender_id != pc.l2id
      Util.punish(pc, "tried to cancel another player's post attachments.")
      return
    end

    unless pc.inside_peace_zone?
      pc.send_packet(SystemMessageId::CANT_CANCEL_NOT_IN_PEACE_ZONE)
      return
    end

    if pc.active_trade_list
      pc.send_packet(SystemMessageId::CANT_CANCEL_DURING_EXCHANGE)
      return
    end

    if pc.enchanting?
      pc.send_packet(SystemMessageId::CANT_CANCEL_DURING_ENCHANT)
      return
    end

    unless pc.private_store_type.none?
      pc.send_packet(SystemMessageId::CANT_CANCEL_PRIVATE_STORE)
      return
    end

    unless msg.has_attachments?
      pc.send_packet(SystemMessageId::YOU_CANT_CANCEL_RECEIVED_MAIL)
      return
    end

    attachments = msg.attachments

    if attachments.nil? || attachments.size == 0
      pc.send_packet(SystemMessageId::YOU_CANT_CANCEL_RECEIVED_MAIL)
      return
    end

    weight = 0
    slots = 0

    attachments.items.each do |item|
      if item.owner_id != pc.l2id
        Util.punish(pc, "tried to get mail attachment from a cancelled mail.")
        return
      end

      unless item.item_location.mail?
        Util.punish(pc, "tried to get items from another mail.")
        return
      end

      if item.location_slot != msg.id
        Util.punish(pc, "tried to get items from a different mail attachment.")
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
      pc.send_packet(SystemMessageId::CANT_CANCEL_INVENTORY_FULL)
      return
    end

    unless pc.inventory.validate_weight(weight)
      pc.send_packet(SystemMessageId::CANT_CANCEL_INVENTORY_FULL)
      return
    end

    if Config.force_inventory_update
      iu = InventoryUpdate.new
    end

    attachments.items.safe_each do |item|
      count = item.count

      new_item = attachments.transfer_item(attachments.name, item.l2id, count, pc.inventory, pc, nil)
      unless new_item
        warn { "Failed to transfer item to #{pc.name}'s inventory." }
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

    msg.remove_attachments

    if iu
      pc.send_packet(iu)
    else
      pc.send_packet(ItemList.new(pc, false))
    end

    pc.send_packet(StatusUpdate.current_load(pc))

    if rcv = L2World.get_player(msg.receiver_id)
      sm = SystemMessage.s1_cancelled_mail
      sm.add_char_name(pc)
      rcv.send_packet(sm)
      rcv.send_packet(ExChangePostState.new(true, @msg_id, Message::DELETED))
    end

    MailManager.delete_message_in_db(@msg_id)

    pc.send_packet(ExChangePostState.new(false, @msg_id, Message::DELETED))
    pc.send_packet(SystemMessageId::MAIL_SUCCESSFULLY_CANCELLED)
  end
end
