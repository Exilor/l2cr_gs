class Packets::Incoming::RequestExShowContactList < GameClientPacket
  private def read_impl
    # no-op
  end

  private def run_impl
    return unless Config.allow_mail
    return unless pc = active_char
    pc.send_packet(ExShowContactList.new(pc))
  end
end
