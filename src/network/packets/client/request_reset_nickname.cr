class Packets::Incoming::RequestResetNickname < GameClientPacket
  private def read_impl
    # no-op
  end

  private def run_impl
    return unless pc = active_char

    pc.appearance.title_color = 0xFFFF77
    pc.title = ""
    pc.broadcast_title_info
  end
end
