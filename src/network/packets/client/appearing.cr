class Packets::Incoming::Appearing < GameClientPacket
  no_action_request

  private def read_impl
    # no-op
  end

  private def run_impl
    return unless pc = active_char

    if pc.teleporting?
      pc.on_teleported
    end

    send_packet(UserInfo.new(pc))
    send_packet(ExBrExtraUserInfo.new(pc))
  end
end
