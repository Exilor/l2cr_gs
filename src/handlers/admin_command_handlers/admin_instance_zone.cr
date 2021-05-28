module AdminCommandHandler::AdminInstanceZone
  extend self
  extend AdminCommandHandler

  def use_admin_command(command : String, pc : L2PcInstance) : Bool
    target = pc.target.try &.name || "no-target"
    GMAudit.log(pc, command, target, "")

    if command.starts_with?("admin_instancezone_clear")
      begin
        st = command.split

        st.shift
        player = L2World.get_player(st.shift).not_nil!
        instance_id = st.shift.to_i
        name = InstanceManager.get_instance_id_name(instance_id)
        InstanceManager.delete_instance_time(player.l2id, instance_id)
        pc.send_message("Instance zone #{name} cleared for player #{player}")
        player.send_message("Admin cleared instance zone #{name} for you")

        return true
      rescue e
        warn e
        pc.send_message("Failed clearing instance time: #{e.message}")
        pc.send_message("Usage: #instancezone_clear <player_name> [instanceId]")
        return false
      end
    elsif command.starts_with?("admin_instancezone")
      st = command.split
      st.shift?

      if !st.empty?
        player_name = st.shift

        begin
          player = L2World.get_player(player_name)
        rescue e
          warn e
        end

        if player
          display(player, pc)
        else
          pc.send_message("The player #{player_name} is not online")
          pc.send_message("Usage: #instancezone [playername]")
          return false
        end
      elsif pc_target = pc.target.as?(L2PcInstance)
        display(pc_target, pc)
      else
        display(pc, pc)
      end
    end

    true
  end

  private def display(player, pc)
    times = InstanceManager.get_all_instance_times(player.l2id)

    html = String.build(500 &+ (times.size &* 200)) do |io|
      io << "<html><center><table width=260><tr>" \
            "<td width=40><button value=\"Main\" action=\"bypass -h admin_admin\" width=40 height=21 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td>" \
            "<td width=180><center>Character Instances</center></td>" \
            "<td width=40><button value=\"Back\" action=\"bypass -h admin_current_player\" width=40 height=21 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td>" \
            "</tr></table><br><font color=\"LEVEL\">Instances for "
      io << player.name
      io << "</font><center><br>" \
            "<table>" \
            "<tr><td width=150>Name</td><td width=50>Time</td><td width=70>Action</td></tr>"

      times.each do |id, time|
        hours = 0
        minutes = 0
        remaining_time = (time - Time.ms) // 1000
        if remaining_time > 0
          hours = (remaining_time // 3600).to_i
          minutes = ((remaining_time % 3600) // 60).to_i
        end

        io << "<tr><td>"
        io << InstanceManager.get_instance_id_name(id)
        io << "</td><td>"
        io << hours
        io << ":"
        io << minutes
        io << "</td><td><button value=\"Clear\" action=\"bypass -h admin_instancezone_clear "
        io << player.name
        io << " "
        io << id
        io << "\" width=60 height=15 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td></tr>"
      end

      io << "</table></html>"
    end

    ms = NpcHtmlMessage.new
    ms.html = html

    pc.send_packet(ms)
  end

  def commands : Enumerable(String)
    {
      "admin_instancezone",
      "admin_instancezone_clear"
    }
  end
end
