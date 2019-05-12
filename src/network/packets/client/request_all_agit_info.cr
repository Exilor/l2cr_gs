class Packets::Incoming::RequestAllAgitInfo < GameClientPacket
  private def read_impl
    # no-op
  end

  private def run_impl
    client?.try &.send_packet(ExShowAgitInfo::STATIC_PACKET)
  end
end
