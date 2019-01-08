class MessageDeletionTask
  include Runnable
  include Loggable

  initializer msg_id: Int32

  def run
    unless msg = MailManager.get_message(@msg_id)
      return
    end

    if msg.has_attachments?
      begin
        if sender = L2World.get_player(msg.sender_id)
          msg.attachments!.return_to_wh(sender.warehouse)
          sender.send_packet(SystemMessageId::MAIL_RETURNED)
        else
          msg.attachments!.return_to_wh(nil)
        end

        msg.attachments!.delete_me
        msg.remove_attachments

        if receiver = L2World.get_player(msg.receiver_id)
          receiver.send_packet(SystemMessageId::MAIL_RETURNED)
        end
      rescue e
        error e
      end
    end

    MailManager.delete_message_in_db(msg.id)
  end
end
