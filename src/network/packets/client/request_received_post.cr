class Packets::Incoming::RequestReceivedPost < GameClientPacket
  no_action_request

  @msg_id = 0

  def read_impl
    @msg_id = d
  end

  def run_impl
    return unless Config.allow_mail
    return unless pc = active_char

    unless msg = MailManager.get_message(@msg_id)
      warn "Message with ID #{@msg_id} not found."
      return
    end

    if !pc.inside_peace_zone? && msg.has_attachments?
      pc.send_packet(SystemMessageId::CANT_USE_MAIL_OUTSIDE_PEACE_ZONE)
      return
    end

    if msg.receiver_id != pc.l2id
      Util.punish(pc, "tried to receive a message sent to somebody else.")
      warn "#{pc.name} tried to receive a message not addressed to him."
      return
    end

    if msg.deleted_by_receiver?
      debug "Message with ID #{@msg_id} was deleted by receiver."
      return
    end

    pc.send_packet(ExReplyReceivedPost.new(msg))
    pc.send_packet(ExChangePostState.new(true, @msg_id, Message::READ))
    msg.mark_as_read
  end
end
