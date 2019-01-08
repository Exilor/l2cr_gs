class Packets::Incoming::DummyPacket < GameClientPacket
  def read_impl
    # no-op
  end

  def run_impl
    # no-op
  end
end
