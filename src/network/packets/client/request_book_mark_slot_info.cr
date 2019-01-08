class Packets::Incoming::RequestBookMarkSlotInfo < GameClientPacket
  def read_impl
    # no-op
  end

  def run_impl
    return unless pc = active_char
    pc.send_packet(ExGetBookMarkInfoPacket.new(pc))
  end
end
