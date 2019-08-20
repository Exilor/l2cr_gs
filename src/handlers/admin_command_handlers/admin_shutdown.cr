module AdminCommandHandler::AdminShutdown
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    if command.starts_with?("admin_server_shutdown")
      begin
        val = command.from(22)
        if val.num?
          server_shutdown(pc, val.to_i, false)
        else
          pc.send_message("Usage: #server_shutdown <seconds>")
          send_html_form(pc)
        end
      rescue
        send_html_form(pc)
      end
    elsif command.starts_with?("admin_server_restart")
      begin
        val = command.from(21)
        if val.num?
          server_shutdown(pc, val.to_i, true)
        else
          pc.send_message("Usage: #server_restart <seconds>")
          send_html_form(pc)
        end
      rescue
        send_html_form(pc)
      end
    elsif command.starts_with?("admin_server_abort")
      server_abort(pc)
    end

    true
  end

  private def send_html_form(pc)
    html = Packets::Outgoing::NpcHtmlMessage.new
    h, m = GameTimer.time.divmod(60)

    cal = Calendar.new
    cal.hour = h
    cal.minute = m
    html.set_file(pc, "data/html/admin/shutdown.htm")
    html["%count%"] = L2World.all_players_count
    html["%used%"] = "TODO: get memory usage"
    html["%time%"] = cal.time.to_s("%I:%M %p")
    pc.send_packet(html)
  end

  private def server_shutdown(pc, seconds, restart)
    Shutdown.start_shutdown(pc, seconds, restart)
  end

  private def server_abort(pc)
    Shutdown.abort(pc)
  end

  def commands
    {
      "admin_server_shutdown",
      "admin_server_restart",
      "admin_server_abort"
    }
  end
end
