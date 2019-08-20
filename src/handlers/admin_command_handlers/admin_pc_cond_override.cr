module AdminCommandHandler::AdminPcCondOverride
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    st = command.split
    unless st.empty?
      case st.shift
      when "admin_exceptions"
        msg = Packets::Outgoing::NpcHtmlMessage.new(0, 1)
        msg.set_file(pc, "data/html/admin/cond_override.htm")
        sb = String.build do |io|
          PcCondOverride.each do |ex|
            io << "<tr><td fixwidth=\"180\">"
            io << ex.description
            io << ":</td><td><a action=\"bypass -h admin_set_exception "
            io << ex.to_i
            io << "\">"
            io << (pc.can_override_cond?(ex) ? "Disable" : "Enable")
            io << "</a></td></tr>"
          end
        end
        msg["%cond_table%"] = sb
        pc.send_packet(msg)
      when "admin_set_exception"
        unless st.empty?
          token = st.shift
          if token.num?
            if ex = PcCondOverride[token.to_i]?
              if pc.can_override_cond?(ex)
                pc.remove_overrided_cond(ex)
                pc.send_message("You've disabled #{ex.description}")
              else
                pc.add_override_cond(ex)
                pc.send_message("You've enabled #{ex.description}")
              end
            end
          else
            case token
            when "enable_all"
              PcCondOverride.each do |ex|
                unless pc.can_override_cond?(ex)
                  pc.add_override_cond(ex)
                end
              end
              pc.send_message("All condition exceptions have been enabled.")
            when "disable_all"
              PcCondOverride.each do |ex|
                if pc.can_override_cond?(ex)
                  pc.remove_overrided_cond(ex)
                end
              end
              pc.send_message("All condition exceptions have been disabled.")
            end
          end

          use_admin_command(commands[0], pc)
        end
      end
    end

    true
  end

  def commands
    {
      "admin_exceptions",
      "admin_set_exception"
    }
  end
end
