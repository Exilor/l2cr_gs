class Packets::Incoming::RequestChangeBookMarkSlot < GameClientPacket
  private def read_impl
    # no-op
  end

  private def run_impl
    # L2J doesn't do anything.
  end
end
