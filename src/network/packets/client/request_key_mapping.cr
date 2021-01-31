class Packets::Incoming::RequestKeyMapping < GameClientPacket
  no_action_request

  private def read_impl
    # no-op
  end

  private def run_impl
    if Config.store_ui_settings && (pc = active_char)
      pc.send_packet(ExUConcurrent::Setting.new(pc))
    end
  end
end
