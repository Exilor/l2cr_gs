class Packets::Incoming::RequestSentPost < GameClientPacket
  no_action_request

  @msg_id = 0

  private def read_impl
    @msg_id = d
  end

  private def run_impl
    return unless Config.allow_mail
    return unless pc = active_char

    unless msg = MailManager.get_message(@msg_id)
      warn { "Message with id #{@msg_id} not found." }
      return
    end

    if !pc.inside_peace_zone? && msg.has_attachments?
      pc.send_packet(SystemMessageId::CANT_USE_MAIL_OUTSIDE_PEACE_ZONE)
      return
    end

    if msg.sender_id != pc.l2id
      Util.punish(pc, "tried to read a mail message sent to somebody else.")
      warn { "Player #{pc.name} tried to read a sent post he didn't send." }
      return
    end

    if msg.deleted_by_sender?
      debug { "Message with id #{@msg_id} was deleted by the sender." }
      return
    end

    pc.send_packet(ExReplySentPost.new(msg))
  end
end
