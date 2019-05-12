class Packets::Incoming::RequestShowMiniMap < GameClientPacket
  no_action_request

  private def read_impl
    # no-op
  end

  private def run_impl
    return unless pc = active_char
    pc.send_packet(ShowMiniMap.new(1665))
  end
end
