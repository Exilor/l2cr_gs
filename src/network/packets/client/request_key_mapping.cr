class Packets::Incoming::RequestKeyMapping < GameClientPacket
  no_action_request

  def read_impl
    # no-op
  end

  def run_impl
    return unless pc = active_char

    if Config.store_ui_settings
      pc.send_packet(ExUISetting.new(pc))
    end
  end
end
