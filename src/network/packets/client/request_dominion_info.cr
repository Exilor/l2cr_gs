class Packets::Incoming::RequestDominionInfo < GameClientPacket
  no_action_request

  private def read_impl
    # no-op
  end

  private def run_impl
    send_packet(ExReplyDominionInfo::STATIC_PACKET)
    send_packet(ExShowOwnthingPos::STATIC_PACKET)
  end
end
