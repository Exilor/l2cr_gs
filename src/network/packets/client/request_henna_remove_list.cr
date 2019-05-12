class Packets::Incoming::RequestHennaRemoveList < GameClientPacket
  private def read_impl
    # @unknown = d
  end

  private def run_impl
    return unless pc = active_char
    pc.send_packet(HennaRemoveList.new(pc))
  end
end
