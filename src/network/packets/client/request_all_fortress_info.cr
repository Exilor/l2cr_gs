class Packets::Incoming::RequestAllFortressInfo < GameClientPacket
  no_action_request

  def read_impl
    # no-op
  end

  def run_impl
    client?.try &.send_packet(ExShowFortressInfo::STATIC_PACKET)
  end
end
