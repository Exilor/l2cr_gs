class Packets::Incoming::RequestDeleteSentPost < GameClientPacket
  no_action_request

  @msg_ids : Slice(Int32)?

  BATCH_LENGTH = 4

  private def read_impl
    count = d
    if count <= 0 || count > Config.max_item_in_packet
      return
    end
    if count * BATCH_LENGTH != buffer.remaining
      return
    end
    @msg_ids = Slice.new(count) { d }
  end

  private def run_impl
    return unless Config.allow_mail
    return unless pc = active_char

    unless pc.inside_peace_zone?
      pc.send_packet(SystemMessageId::CANT_USE_MAIL_OUTSIDE_PEACE_ZONE)
      return
    end

    return unless msg_ids = @msg_ids

    msg_ids.each do |msg_id|
      unless msg = MailManager.get_message(msg_id)
        warn "Message with ID #{msg_id} not found."
        next
      end

      if msg.sender_id != pc.l2id
        Util.punish(pc, "tried to delete a sent message he didn't send.")
        warn "#{pc.name} tried to delete a sent message he didn't send."
        return
      end

      if msg.has_attachments? || msg.deleted_by_sender?
        return
      end

      msg.set_deleted_by_sender
    end

    pc.send_packet(ExChangePostState.new(false, msg_ids, Message::DELETED))
  end
end
