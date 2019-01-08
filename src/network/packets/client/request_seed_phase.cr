class Packets::Incoming::RequestSeedPhase < GameClientPacket
  def read_impl
    # no-op
  end

  def run_impl
    return unless pc = active_char
    pc.send_packet(ExShowSeedMapInfo::STATIC_PACKET)
  end
end
