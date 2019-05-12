class Packets::Incoming::RequestExFriendListExtended < GameClientPacket
  private def read_impl
    # no-op
  end

  private def run_impl
    return unless Config.allow_mail
    return unless pc = active_char
    pc.send_packet(FriendListExtended.new(pc))
  end
end
