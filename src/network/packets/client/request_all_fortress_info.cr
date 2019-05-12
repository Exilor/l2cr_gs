class Packets::Incoming::RequestAllFortressInfo < GameClientPacket
  no_action_request

  private def read_impl
    # no-op
  end

  private def run_impl
    client?.try &.send_packet(ExShowFortressInfo::STATIC_PACKET)
  end
end
