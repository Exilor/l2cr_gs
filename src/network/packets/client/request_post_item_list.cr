class Packets::Incoming::RequestPostItemList < GameClientPacket
  no_action_request

  private def read_impl
    # no-op
  end

  private def run_impl
    return unless Config.allow_mail && Config.allow_attachments
    return unless pc = active_char

    unless pc.inside_peace_zone?
      pc.send_packet(SystemMessageId::CANT_USE_MAIL_OUTSIDE_PEACE_ZONE)
      return
    end

    pc.send_packet(ExReplyPostItemList.new(pc))
  end
end
