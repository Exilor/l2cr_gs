class Packets::Outgoing::TutorialCloseHtml < GameServerPacket
  static_packet

  def run_impl
    client.not_nil!
    .active_char.not_nil!
    .clear_html_actions(HtmlActionScope::TUTORIAL_HTML)
  end

  def write_impl
    c 0xa9
  end
end
