class Packets::Incoming::RequestExShowContactList < GameClientPacket
  def read_impl
    # no-op
  end

  def run_impl
    return unless Config.allow_mail
    return unless pc = active_char
    pc.send_packet(ExShowContactList.new(pc))
  end
end
