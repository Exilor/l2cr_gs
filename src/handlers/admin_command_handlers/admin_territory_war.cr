module AdminCommandHandler::AdminTerritoryWar
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    st = command.split
    command = st.shift

    if command == "admin_territory_war"
      show_main_page(pc)
    elsif command.casecmp?("admin_territory_war_time")
      if !st.empty?
        cal = Calendar.new
        cal.ms = TerritoryWarManager.tw_start_time_in_millis

        case val = st.shift
        when "month"
          month = cal.month + st.shift.to_i
          unless month.between?(cal.get_minimum(:MONTH), cal.get_maximum(:MONTH))
            pc.send_message("Unable to change Siege Date - Incorrect month value only #{cal.get_minimum(:MONTH)}-#{cal.get_maximum(:MONTH)} is accepted")
            return false
          end
          cal.month = month
        when "day"
          day = st.shift.to_i
          unless day.between?(cal.get_minimum(:DAY), cal.get_maximum(:DAY))
            pc.send_message("Unable to change Siege Date - Incorrect day value only #{cal.get_minimum(:DAY)}-#{cal.get_maximum(:DAY)} is accepted")
            return false
          end
          cal.day = day
        when "hour"
          hour = st.shift.to_i
          unless hour.between?(cal.get_minimum(:HOUR),  cal.get_maximum(:HOUR))
            pc.send_message("Unable to change Siege Date - Incorrect hour value only #{cal.get_minimum(:HOUR)}-#{cal.get_maximum(:HOUR)} is accepted")
            return false
          end
          cal.hour = hour
        when "min"
          min = st.shift.to_i
          unless min.between?(cal.get_minimum(:MINUTE), cal.get_maximum(:MINUTE))
            pc.send_message("Unable to change Siege Date - Incorrect minute value only #{cal.get_minimum(:MINUTE)}-#{cal.get_maximum(:MINUTE)} is accepted")
            return false
          end
          cal.minute = min
        end

        if cal.ms < Time.ms
          pc.send_message("Unable to change TW Date")
        elsif cal.ms != TerritoryWarManager.tw_start_time_in_millis
          TerritoryWarManager.tw_start_time_in_millis = cal.ms
          GlobalVariablesManager[TerritoryWarManager::GLOBAL_VARIABLE] = cal.ms
        end
      end
      show_siege_time_page(pc)
    elsif command.casecmp?("admin_territory_war_start")
      TerritoryWarManager.tw_start_time_in_millis = Time.ms
    elsif command.casecmp?("admin_territory_war_end")
      TerritoryWarManager.tw_start_time_in_millis = Time.ms - TerritoryWarManager.war_length
    elsif command.casecmp?("admin_territory_wards_list")
      html_msg = NpcHtmlMessage.new(0, 1)
      sb = String.build do |io|
        io << "<html><title>Territory War</title><body><br><center><font color=\"LEVEL\">Active Wards List:</font></center>"

        if TerritoryWarManager.tw_in_progress?
          TerritoryWarManager.territory_wards.each do |ward|
            if npc = ward.npc?
              io << "<table width=270><tr>"
              io << "<td width=135 ALIGN=\"LEFT\">"
              io << npc.name
              io << "</td>"
              io << "<td width=135 ALIGN=\"RIGHT\"><button value=\"TeleTo\" action=\"bypass -h admin_move_to "
              io << npc.x
              io << " "
              io << npc.y
              io << " "
              io << npc.z
              io << "\" width=50 height=20 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_ct1.button_df\"></td>"
              io << "</tr></table>"
            elsif player = ward.player?
              io << "<table width=270><tr>"
              io << "<td width=135 ALIGN=\"LEFT\">"
              io << player.active_weapon_instance.item_name
              io << " - "
              io << player.name
              io << "</td>"
              io << "<td width=135 ALIGN=\"RIGHT\"><button value=\"TeleTo\" action=\"bypass -h admin_move_to "
              io << player.x
              io << " "
              io << player.y
              io << " "
              io << player.z
              io << "\" width=50 height=20 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_ct1.button_df\"></td>"
              io << "</tr></table>"
            end
          end
          io << "<br><center><button value=\"Back\" action=\"bypass -h admin_territory_war\" width=50 height=21 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></center></body></html>"
        else
          io << "<br><br><center>The Ward List is empty!<br>TW has probably NOT started"
          io << "<br><button value=\"Back\" action=\"bypass -h admin_territory_war\" width=50 height=21 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></center></body></html>"
        end
      end

      html_msg.html = sb
      pc.send_packet(html_msg)
    end

    true
  end

  private def show_siege_time_page(pc)
    reply = NpcHtmlMessage.new
    reply.set_file(pc, "data/html/admin/territorywartime.htm")
    reply["%time%"] = TerritoryWarManager.tw_start.time
    pc.send_packet(reply)
  end

  private def show_main_page(pc)
    AdminHtml.show_admin_html(pc, "territorywar.htm")
  end

  def commands
    {
      "admin_territory_war",
      "admin_territory_war_time",
      "admin_territory_war_start",
      "admin_territory_war_end",
      "admin_territory_wards_list"
    }
  end
end
