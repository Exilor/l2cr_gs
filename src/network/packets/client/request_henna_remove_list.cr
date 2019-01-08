class Packets::Incoming::RequestHennaRemoveList < GameClientPacket
  def read_impl
    # @unknown = d
  end

  def run_impl
    return unless pc = active_char
    pc.send_packet(HennaRemoveList.new(pc))
  end
end
