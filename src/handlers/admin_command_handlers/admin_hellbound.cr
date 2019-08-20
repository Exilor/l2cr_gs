module AdminCommandHandler::AdminHellbound
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    if command.starts_with?(commands[0])
      begin
        st = command.split
        st.shift
        level = st.shift.to_i
        if level < 0 || level > 11
          pc.send_message("Level must be between 0 and 10")
          return false
        end

        HellboundEngine.level = level
        pc.send_message("Hellbound level set to #{level}")
        return true
      rescue e
        pc.send_message("Usage: #hellbound_setlevel 0-11")
        return false
      end
    elsif command.starts_with?(commands[1])
      show_menu(pc)
      return true
    end

    false
  end

  private def show_menu(pc)
    html = Packets::Outgoing::NpcHtmlMessage.new
    html.set_file(pc, "data/html/admin/hellbound.htm")
    html["%hbstage%"] = HellboundEngine.level
    html["%trust%"] = HellboundEngine.trust
    html["%maxtrust%"] = HellboundEngine.max_trust
    html["%mintrust%"] = HellboundEngine.min_trust
    pc.send_packet(html)
  end

  def commands
    {
      "admin_hellbound_setlevel",
      "admin_hellbound"
    }
  end
end
