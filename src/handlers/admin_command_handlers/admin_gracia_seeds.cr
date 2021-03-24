module AdminCommandHandler::AdminGraciaSeeds
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    st = command.split
    actual_cmd = st.shift

    val = st.shift { "" }

    if actual_cmd.casecmp?("admin_kill_tiat")
      GraciaSeedsManager.increase_sod_tiat_killed
    elsif actual_cmd.casecmp?("admin_set_sodstate")
      GraciaSeedsManager.set_sod_state(val.to_i, true)
    end

    show_menu(pc)

    true
  end

  private def show_menu(pc)
    html = NpcHtmlMessage.new
    html.set_file(pc, "data/html/admin/graciaseeds.htm")
    html["%sodstate%"] = GraciaSeedsManager.sod_state
    html["%sodtiatkill%"] = GraciaSeedsManager.sod_tiat_killed
    if GraciaSeedsManager.sod_time_for_next_state_change > 0
      next_change_date = Calendar.new
      next_change_date.ms = Time.ms &+ GraciaSeedsManager.sod_time_for_next_state_change
      html["%sodtime%"] = next_change_date.time
    else
      html["%sodtime%"] = "-1"
    end

    pc.send_packet(html)
  end

  def commands : Enumerable(String)
    {
      "admin_gracia_seeds",
      "admin_kill_tiat",
      "admin_set_sodstate"
    }
  end
end
