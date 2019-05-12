class Packets::Incoming::RequestSentPostList < GameClientPacket
  no_action_request

  private def read_impl
    # no-op
  end

  private def run_impl
    return unless Config.allow_mail
    return unless pc = active_char

    pc.send_packet(ExShowSentPostList.new(pc.l2id))
  end
end
