class Packets::Incoming::RequestRejectPostAttachment < GameClientPacket
  no_action_request

  @msg_id = 0

  private def read_impl
    @msg_id = d
  end

  private def run_impl
    return unless Config.allow_mail && Config.allow_attachments
    return unless pc = active_char

    unless flood_protectors.transaction.try_perform_action("rejectattach")
      debug "Flood detected."
      return
    end

    unless pc.inside_peace_zone?
      pc.send_packet(SystemMessageId::CANT_USE_MAIL_OUTSIDE_PEACE_ZONE)
      return
    end

    unless msg = MailManager.get_message(@msg_id)
      warn { "Message with ID #{@msg_id} not found." }
      return
    end

    if msg.receiver_id != pc.l2id
      Util.punish(pc, "tried to reject a mail attachment owned by another player.")
      warn { "#{pc.name} tried to reject a message meant to another player." }
      return
    end

    if !msg.has_attachments? || msg.send_by_system != 0
      return
    end

    MailManager.send_message(Message.new(msg))

    pc.send_packet(SystemMessageId::MAIL_SUCCESSFULLY_RETURNED)
    pc.send_packet(ExChangePostState.new(true, @msg_id, Message::REJECTED))

    if sender = L2World.get_player(msg.sender_id)
      sm = SystemMessage.s1_returned_mail
      sm.add_char_name(pc)
      sender.send_packet(sm)
    end
  end
end
