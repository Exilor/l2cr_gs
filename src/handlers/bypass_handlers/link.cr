module BypassHandler::Link
  extend self
  extend BypassHandler

  def use_bypass(command, pc, target) : Bool
    html_path = command.from(4).strip

    if html_path.empty?
      warn { "#{pc} sent an empty html link bypass request." }
      return false
    end

    if html_path.includes?("..")
      warn { "#{pc} sent an invalid html link bypass request." }
      return false
    end

    file_name = "data/html/" + html_path
    l2id = target.try &.l2id || 0
    html = NpcHtmlMessage.new(l2id)
    html.set_file(pc, file_name)
    html["%objectId%"] = l2id
    pc.send_packet(html)

    true
  end

  def commands
    {"Link"}
  end
end
