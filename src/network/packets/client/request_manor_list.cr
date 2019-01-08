class Packets::Incoming::RequestManorList < GameClientPacket
  no_action_request

  def read_impl
    # no-op
  end

  def run_impl
    send_packet(ExSendManorList::STATIC_PACKET)
  end
end
