class Packets::Incoming::RequestSendPost < GameClientPacket
  no_action_request

  BATCH_LENGTH = 12

  MAX_RECV_LENGTH = 16
  MAX_SUBJ_LENGTH = 128
  MAX_TEXT_LENGTH = 512
  MAX_ATTACHMENTS = 8
  INBOX_SIZE = 240
  OUTBOX_SIZE = 240

  MESSAGE_FEE = 100i64
  MESSAGE_FEE_PER_SLOT = 1000i64

  private record AttachmentItem, l2id : Int32, count : Int64

  @receiver = ""
  @is_cod = false
  @subject = ""
  @text = ""
  @req_adena = 0i64
  @items : Slice(AttachmentItem)?

  private def read_impl
    @receiver = s
    @is_cod = d != 0
    @subject = s
    @text = s

    attach_count = d

    if attach_count < 0 || attach_count > Config.max_item_in_packet
      debug "attach_count (#{attach_count}) outside of accepted values."
      return
    end

    if (attach_count * BATCH_LENGTH) + 8 != buffer.remaining
      debug "Buffer remaining size mismatch."
      debug "Should be #{(attach_count * BATCH_LENGTH) + 8} but is #{buffer.remaining}."
      debug "(attach_count: #{attach_count})"
      return
    end

    if attach_count > 0
      items = Slice.new(attach_count) do
        id = d
        count = q
        if id < 1 || count < 0
          return
        end

        AttachmentItem.new(id, count)
      end
    end

    @items = items

    @req_adena = q
  end

  private def run_impl
    return unless Config.allow_mail
    return unless pc = active_char

    # if @items
    #   debug "Items:"
    #   @items.each { |it| debug it }
    # else
    #   debug "No items to be sent."
    # end

    unless Config.allow_attachments
      @items = nil
      @is_cod = false
      @req_adena = 0i64
    end

    unless pc.access_level.allow_transaction?
      pc.send_message("Transactions are disabled for your Access Level.")
      return
    end

    if !pc.inside_peace_zone? && @items
      pc.send_packet(SystemMessageId::CANT_FORWARD_NOT_IN_PEACE_ZONE)
      return
    end

    if pc.active_trade_list
      pc.send_packet(SystemMessageId::CANT_FORWARD_DURING_EXCHANGE)
      return
    end

    if pc.enchanting?
      pc.send_packet(SystemMessageId::CANT_FORWARD_DURING_ENCHANT)
      return
    end

    unless pc.private_store_type.none?
      pc.send_packet(SystemMessageId::CANT_FORWARD_PRIVATE_STORE)
      return
    end

    if @receiver.size > MAX_RECV_LENGTH
      pc.send_packet(SystemMessageId::ALLOWED_LENGTH_FOR_TITLE_EXCEEDED)
      return
    end

    items = @items

    if items && items.size > MAX_ATTACHMENTS
      pc.send_packet(SystemMessageId::ITEM_SELECTION_POSSIBLE_UP_TO_8)
      return
    end

    if @req_adena < 0 || @req_adena > Inventory.max_adena
      return
    end

    if @is_cod
      if @req_adena == 0
        pc.send_packet(SystemMessageId::PAYMENT_AMOUNT_NOT_ENTERED)
        return
      end

      if items.nil? || items.empty?
        pc.send_packet(SystemMessageId::PAYMENT_REQUEST_NO_ITEM)
        return
      end
    end

    receiver_id = CharNameTable.get_id_by_name(@receiver)

    if receiver_id <= 0
      pc.send_packet(SystemMessageId::RECIPIENT_NOT_EXIST)
      return
    end

    level = CharNameTable.get_access_level_by_id(receiver_id)
    access_level = AdminData.get_access_level(level)

    if access_level.gm? && !pc.access_level.gm?
      sm = SystemMessage.cannot_mail_gm_c1
      sm.add_string(@receiver)
      pc.send_packet(sm)
      return
    end

    if pc.jailed? && ((Config.jail_disable_transaction && @items) || Config.jail_disable_chat)
      pc.send_packet(SystemMessageId::CANT_FORWARD_NOT_IN_PEACE_ZONE)
      return
    end

    if BlockList.in_block_list?(receiver_id, pc.l2id)
      sm = SystemMessage.c1_blocked_you_cannot_mail
      sm.add_string(@receiver)
      pc.send_packet(sm)
      return
    end

    if MailManager.get_outbox_size(pc.l2id) >= OUTBOX_SIZE
      pc.send_packet(SystemMessageId::CANT_FORWARD_MAIL_LIMIT_EXCEEDED)
      return
    end

    if MailManager.get_inbox_size(receiver_id) >= INBOX_SIZE
      pc.send_packet(SystemMessageId::CANT_FORWARD_MAIL_LIMIT_EXCEEDED)
      return
    end

    unless flood_protectors.send_mail.try_perform_action("sendmail")
      pc.send_packet(SystemMessageId::CANT_FORWARD_LESS_THAN_MINUTE)
      return
    end

    msg = Message.new(pc.l2id, receiver_id, @is_cod, @subject, @text, @req_adena)
    if remove_items(pc, msg)
      MailManager.send_message(msg)
      pc.send_packet(ExNoticePostSent::TRUE)
      pc.send_packet(SystemMessageId::MAIL_SUCCESSFULLY_SENT)
    end
  end

  private def remove_items(pc, msg) : Bool
    current_adena = pc.adena
    fee = MESSAGE_FEE

    @items.try &.each do |i|
      item = pc.check_item_manipulation(i.l2id, i.count, "attach")
      if item.nil? || (!item.tradeable? || item.equipped?)
        pc.send_packet(SystemMessageId::CANT_FORWARD_BAD_ITEM)
        return false
      end

      fee += MESSAGE_FEE_PER_SLOT

      if item.id == Inventory::ADENA_ID
        current_adena -= i.count
      end
    end

    if current_adena < fee || !pc.reduce_adena("MailFee", fee, nil, false)
      pc.send_packet(SystemMessageId::CANT_FORWARD_NO_ADENA)
      return false
    end

    return true unless _items = @items

    unless attachments = msg.create_attachments
      debug "Message#create_attachments returned false/nil."
      return false
    end

    receiver = "#{msg.receiver_name}[#{msg.receiver_id}]"

    unless Config.force_inventory_update
      iu = InventoryUpdate.new
    end

    _items.each do |i|
      old_item = pc.check_item_manipulation(i.l2id, i.count, "attach")
      if old_item.nil? || (!old_item.tradeable? || old_item.equipped?)
        warn "Error adding attachment for #{pc.name} (old_item is nil)."
        return false
      end

      new_item = pc.inventory.transfer_item("SendMail", i.l2id, i.count, attachments, pc, receiver)
      unless new_item
        warn "Error adding attachment for #{pc.name} (new_item is nil)."
        next
      end
      new_item.set_item_location(new_item.item_location, msg.id)

      if iu
        if old_item.count > 0 && old_item != new_item
          iu.add_modified_item(old_item)
        else
          iu.add_removed_item(old_item)
        end
      end
    end

    if iu
      pc.send_packet(iu)
    else
      pc.send_packet(ItemList.new(pc, false))
    end

    pc.send_packet(StatusUpdate.current_load(pc))

    true
  end
end
