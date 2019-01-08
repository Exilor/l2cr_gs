class Packets::Incoming::RequestAllCastleInfo < GameClientPacket
  no_action_request

  def read_impl
    # no-op
  end

  def run_impl
    client?.try &.send_packet(ExShowCastleInfo::STATIC_PACKET)
  end
end
