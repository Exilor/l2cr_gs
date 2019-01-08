class Packets::Incoming::RequestChangeBookMarkSlot < GameClientPacket
  def read_impl
    # no-op
  end

  def run_impl
    # L2J doesn't do anything.
  end
end
