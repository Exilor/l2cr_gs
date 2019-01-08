class Packets::Incoming::RequestSentPostList < GameClientPacket
  no_action_request

  def read_impl
    # no-op
  end

  def run_impl
    return unless Config.allow_mail
    return unless pc = active_char

    pc.send_packet(ExShowSentPostList.new(pc.l2id))
  end
end
