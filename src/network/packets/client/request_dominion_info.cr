class Packets::Incoming::RequestDominionInfo < GameClientPacket
  no_action_request

  def read_impl
    # no-op
  end

  def run_impl
    send_packet(ExReplyDominionInfo::STATIC_PACKET)
    send_packet(ExShowOwnthingPos::STATIC_PACKET)
  end
end
