class Packets::Incoming::DummyPacket < GameClientPacket
  private def read_impl
    # no-op
  end

  private def run_impl
    # no-op
  end
end
