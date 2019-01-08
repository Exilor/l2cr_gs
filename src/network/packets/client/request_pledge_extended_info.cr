class Packets::Incoming::RequestPledgeExtendedInfo < GameClientPacket
  def read_impl
    name = s
  end

  def run_impl
    warn "Not implemented (by L2J)."
  end
end
