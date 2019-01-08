class Packets::Incoming::RequestShowMiniMap < GameClientPacket
  no_action_request

  def read_impl
    # no-op
  end

  def run_impl
    return unless pc = active_char
    pc.send_packet(ShowMiniMap.new(1665))
  end
end
