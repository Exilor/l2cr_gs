class Packets::Incoming::RequestAllAgitInfo < GameClientPacket
  def read_impl
    # no-op
  end

  def run_impl
    client?.try &.send_packet(ExShowAgitInfo::STATIC_PACKET)
  end
end
