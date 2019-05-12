class Packets::Incoming::RequestReceivedPostList < GameClientPacket
  no_action_request

  private def read_impl
    # no-op
  end

  private def run_impl
    return unless pc = active_char
    pc.send_packet(ExShowReceivedPostList.new(pc.l2id))
  end
end
