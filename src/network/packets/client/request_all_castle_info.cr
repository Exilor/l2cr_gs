class Packets::Incoming::RequestAllCastleInfo < GameClientPacket
  no_action_request

  private def read_impl
    # no-op
  end

  private def run_impl
    client?.try &.send_packet(ExShowCastleInfo::STATIC_PACKET)
  end
end
