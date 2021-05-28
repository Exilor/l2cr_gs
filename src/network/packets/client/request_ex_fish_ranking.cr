class Packets::Incoming::RequestExFishRanking < GameClientPacket
  private def read_impl
    # no-op
  end

  private def run_impl
    warn "Not implemented (not by L2J either)."
  end
end
