class Packets::Incoming::MoveWithDelta < GameClientPacket
  @dx = 0
  @dy = 0
  @dz = 0

  private def read_impl
    @dx = d
    @dy = d
    @dz = d
  end

  private def run_impl
    # Not implemented (not by L2J either)
  end
end
