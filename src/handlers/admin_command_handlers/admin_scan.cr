module AdminCommandHandler::AdminScan
  extend self
  extend AdminCommandHandler

  private DEFAULT_RADIUS = 500

  def use_admin_command(command, pc)
    st = command.split
    actual_command = st.shift

    case actual_command.casecmp
    when "admin_scan"
      radius = DEFAULT_RADIUS
      unless st.empty?
        begin
          radius = st.shift.to_i
        rescue
          pc.send_message("Usage: #scan [radius]")
          return false
        end
      end

      send_npc_list(pc, radius)
    when "admin_deletenpcbyobjectid"
      if st.empty?
        pc.send_message("Usage: #deletenpcbyobjectid <object_id>")
        return false
      end

      begin
        l2id = st.shift.to_i

        target = L2World.find_object(l2id)
        unless npc = target.as?(L2Npc)
          pc.send_message("NPC does not exist or object_id does not belong to an NPC")
          return false
        end

        npc.delete_me

        if spwn = npc.spawn?
          spwn.stop_respawn

          if RaidBossSpawnManager.defined?(spwn.id)
            RaidBossSpawnManager.delete_spawn(spwn, true)
          else
            SpawnTable.delete_spawn(spwn, true)
          end
        end

        pc.send_message(npc.name + " has been deleted.")
      rescue
        pc.send_message("object_id must be a number.")
        return false
      end

      send_npc_list(pc, DEFAULT_RADIUS)
    end


    true
  end

  private def send_npc_list(pc, radius)
    html = NpcHtmlMessage.new
    html.set_file(pc, "data/html/admin/scan.htm")
    sb = String.build do |io|
      pc.known_list.each_character(radius) do |c|
        next unless c.is_a?(L2Npc)
        io << "<tr><td width=\"54\">"
        io << c.id
        io << "</td><td width=\"54\">"
        io << c.name
        io << "</td><td width=\"54\">"
        io << pc.calculate_distance(c, false, false).round.to_i
        io << "</td><td width=\"54\"><a action=\"bypass -h admin_deleteNpcByObjectId "
        io << c.l2id
        io << "\"><font color=\"LEVEL\">Delete</font></a></td><td width=\"54\"><a action=\"bypass -h admin_move_to "
        io << c.x
        io << " "
        io << c.y
        io << " "
        io << c.z
        io << "\"><font color=\"LEVEL\">Go to</font></a></td></tr>"
      end
    end
    html["%data%"] = sb
    pc.send_packet(html)
  end

  def commands
    {"admin_scan", "admin_deleteNpcByObjectId"}
  end
end
