class Packets::Incoming::MoveWithDelta < GameClientPacket
  @dx = 0
  @dy = 0
  @dz = 0

  def read_impl
    @dx = d
    @dy = d
    @dz = d
  end

  def run_impl
    warn "Not implemented (not by L2J either)."
  end
end
