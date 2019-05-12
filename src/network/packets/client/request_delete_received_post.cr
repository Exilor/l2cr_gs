class Packets::Incoming::RequestDeleteReceivedPost < GameClientPacket
  no_action_request

  BATCH_LENGTH = 4

  @msg_ids : Slice(Int32)?

  private def read_impl
    count = d
    unless 1 <= count <= Config.max_item_in_packet
      return
    end
    if count * BATCH_LENGTH != buffer.remaining
      return
    end

    @msg_ids = Slice.new(count) { d }
  end

  private def run_impl
    return unless Config.allow_mail
    return unless msg_ids = @msg_ids
    return unless pc = active_char

    msg_ids.each do |msg_id|
      unless msg = MailManager.get_message(msg_id)
        warn "No message with ID #{msg_id} found."
        next
      end

      if msg.receiver_id != pc.l2id
        Util.punish(pc, "tried to delete a message that wasn't sent to him.")
        warn "#{pc.name} tried to delete a message that wasn't sent to him."
        return
      end

      if msg.has_attachments? || msg.deleted_by_receiver?
        return
      end

      msg.set_deleted_by_receiver
    end

    pc.send_packet(ExChangePostState.new(true, msg_ids, Message::DELETED))
  end
end
