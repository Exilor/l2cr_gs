class Packets::Incoming::RequestManorList < GameClientPacket
  no_action_request

  private def read_impl
    # no-op
  end

  private def run_impl
    send_packet(ExSendManorList::STATIC_PACKET)
  end
end
