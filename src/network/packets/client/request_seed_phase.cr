class Packets::Incoming::RequestSeedPhase < GameClientPacket
  private def read_impl
    # no-op
  end

  private def run_impl
    return unless pc = active_char
    pc.send_packet(ExShowSeedMapInfo::STATIC_PACKET)
  end
end
