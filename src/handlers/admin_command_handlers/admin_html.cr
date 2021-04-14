module AdminCommandHandler::AdminHtml
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    tokens = command.split

    case tokens.shift?
    when "admin_html"
      if tokens.empty?
        pc.send_message("Usage: //html <path>")
        return false
      end
      show_admin_html(pc, tokens.shift)
    when "admin_loadhtml"
      if tokens.empty?
        pc.send_message("Usage: //loadhtml <path>")
        return false
      end
      show_html(pc, tokens.shift, true)
    end

    true
  end

  def show_admin_html(pc, path)
    show_html(pc, "data/html/admin/" + path, false)
  end

  def show_html(pc, path, reload)
    if reload
      file = File.open("#{Config.datapack_root}/#{path}")
      content = HtmCache.load_file(file)
      file.close
    else
      content = HtmCache.get_htm_force(path)
    end

    html = NpcHtmlMessage.new

    if content
      html.html = content
    else
      html.html = "<html><body>My text is missing:<br>#{path}</body></html>"
    end

    pc.send_packet(html)
  end

  def commands : Enumerable(String)
    {"admin_html", "admin_loadhtml"}
  end
end
