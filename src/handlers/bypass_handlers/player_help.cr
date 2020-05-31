module BypassHandler::PlayerHelp
  extend self
  extend BypassHandler

  def use_bypass(command, pc, target)
    return false if command.size < 13

    path = command.from(12)
    return false if path.includes?("..")
    st = path.split[0].split('#')

    if st.size > 1
      item_id = st[1].to_i
      html = NpcHtmlMessage.new(0, item_id)
    else
      html = NpcHtmlMessage.new
    end

    html.set_file(pc, "data/html/help/" + st[0])
    pc.send_packet(html)

    true
  end

  def commands
    {"player_help"}
  end
end
