module AdminCommandHandler::AdminLogin
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    if command == "admin_server_gm_only"
      gm_only
      pc.send_message("Server is now GM only")
      show_main_page(pc)
    elsif command == "admin_server_all"
      allow_to_all
      pc.send_message("Server is not GM only anymore")
      show_main_page(pc)
    elsif command.starts_with?("admin_server_max_player")
      st = command.split
      if st.size > 1
        st.shift
        number = st.shift
        begin
          LoginServerClient.instance.max_players = number.to_i
          pc.send_message("maxPlayer set to #{number}")
          show_main_page(pc)
        rescue e
          warn e
          pc.send_message("Max players must be a number.")
        end
      else
        pc.send_message("Format is server_max_player <max>")
      end
    elsif command.starts_with?("admin_server_list_type")
      st = command.split
      tokens = st.size
      if tokens > 1
        st.shift
        modes = Array.new(tokens &- 1, "")
        (tokens &- 1).times do |i|
          modes[i] = st.shift.strip
        end
        new_type = 0
        begin
          new_type = modes[0].to_i
        rescue e
          warn e
          new_type = Config.get_server_type_id(modes)
        end
        if Config.server_list_type != new_type
          Config.server_list_type = new_type
          LoginServerClient.instance.send_server_type
          pc.send_message("Server Type changed to #{get_server_type_name(new_type)}")
          show_main_page(pc)
        else
          pc.send_message("Server Type is already #{get_server_type_name(new_type)}")
          show_main_page(pc)
        end
      else
        pc.send_message("Format is server_list_type <normal/relax/test/nolabel/restricted/event/free>")
      end
    elsif command.starts_with?("admin_server_list_age")
      st = command.split
      if st.size > 1
        st.shift
        mode = st.shift
        age = 0
        begin
          age = mode.to_i
          if Config.server_list_age != age
            Config.server_list_type = age
            LoginServerClient.instance.send_server_status(ServerStatus::SERVER_AGE, age)
            pc.send_message("Server Age changed to #{age}")
            show_main_page(pc)
          else
            pc.send_message("Server Age is already #{age}")
            show_main_page(pc)
          end
        rescue e
          warn e
          pc.send_message("Age must be a number")
        end
      else
        pc.send_message("Format is server_list_age <number>")
      end
    elsif command == "admin_server_login"
      show_main_page(pc)
    end

    true
  end

  private def show_main_page(pc)
    html = NpcHtmlMessage.new
    html.set_file(pc, "data/html/admin/login.htm")
    html["%server_name%"] = LoginServerClient.instance.server_name
    html["%status%"] = LoginServerClient.instance.status_string
    html["%clock%"] = get_server_type_name(Config.server_list_type)
    html["%brackets%"] = Config.server_list_bracket
    html["%max_players%"] = LoginServerClient.instance.max_players
    pc.send_packet(html)
  end

  private def get_server_type_name(server_type)
    name_type = ""

    7.times do |i|
      current_type = server_type & Math.pow(2, i).to_i

      if current_type > 0
        unless name_type.empty?
          name_type += "+"
        end

        case current_type
        when 0x01
          name_type += "Normal"
        when 0x02
          name_type += "Relax"
        when 0x04
          name_type += "Test"
        when 0x08
          name_type += "NoLabel"
        when 0x10
          name_type += "Restricted"
        when 0x20
          name_type += "Event"
        when 0x40
          name_type += "Free"
        end
      end
    end

    name_type
  end

  private def allow_to_all
    LoginServerClient.instance.server_status = ServerStatus::STATUS_AUTO
    Config.server_gmonly = false
  end

  private def gm_only
    LoginServerClient.instance.server_status = ServerStatus::STATUS_GM_ONLY
    Config.server_gmonly = true
  end

  def commands
    {
      "admin_server_gm_only",
      "admin_server_all",
      "admin_server_max_player",
      "admin_server_list_type",
      "admin_server_list_age",
      "admin_server_login"
    }
  end
end
