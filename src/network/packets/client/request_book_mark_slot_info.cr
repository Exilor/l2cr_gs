class Packets::Incoming::RequestBookMarkSlotInfo < GameClientPacket
  private def read_impl
    # no-op
  end

  private def run_impl
    return unless pc = active_char
    pc.send_packet(ExGetBookMarkInfoPacket.new(pc))
  end
end
