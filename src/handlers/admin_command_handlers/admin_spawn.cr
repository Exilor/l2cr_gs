module AdminCommandHandler::AdminSpawn
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    if command == "admin_show_spawns"
      AdminHtml.show_admin_html(pc, "spawns.htm")
    elsif command.casecmp?("admin_spawn_debug_menu")
      AdminHtml.show_admin_html(pc, "spawns_debug.htm")
    elsif command.starts_with?("admin_spawn_debug_print")
      st = command.split
      if target = pc.target.as?(L2Npc)
        begin
          st.shift
          type = st.shift.to_i
          print_spawn(target, type)
          if command.includes?("_menu")
            AdminHtml.show_admin_html(pc, "spawns_debug.htm")
          end
        rescue
        end
      else
        pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      end
    elsif command.starts_with?("admin_spawn_index")
      st = command.split
      begin
        st.shift
        level = st.shift.to_i
        from = 0
        begin
          from = st.shift.to_i
        rescue
        end
        show_monsters(pc, level, from)
      rescue
        AdminHtml.show_admin_html(pc, "spawns.htm")
      end
    elsif command == "admin_show_npcs"
      AdminHtml.show_admin_html(pc, "npcs.htm")
    elsif command.starts_with?("admin_npc_index")
      st = command.split
      begin
        st.shift
        letter = st.shift
        from = 0
        begin
          from = st.shift.to_i
        rescue
        end
        show_npcs(pc, letter, from)
      rescue
        AdminHtml.show_admin_html(pc, "npcs.htm")
      end
    elsif command.starts_with?("admin_instance_spawns")
      st = command.split
      begin
        st.shift
        instance = st.shift.to_i
        if instance >= 300000
          counter = 0
          skipped = 0
          if inst = InstanceManager.get_instance(instance)
            html = String.build(500 + 1000) do |io|
              io << "<html><table width=\"100%\"><tr><td width=45><button value=\"Main\" action=\"bypass -h admin_admin\" width=45 height=21 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td><td width=180><center><font color=\"LEVEL\">Spawns for "
              io << instance
              io << "</font></td><td width=45><button value=\"Back\" action=\"bypass -h admin_current_player\" width=45 height=21 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td></tr></table><br><table width=\"100%\"><tr><td width=200>NpcName</td><td width=70>Action</td></tr>"
              inst.npcs.each do |npc|
                if npc.alive?
                  # Only 50 because of client html limitation
                  if counter < 50
                    io << "<tr><td>"
                    io << npc.name
                    io << "</td><td><a action=\"bypass -h admin_move_to "
                    io << npc.x
                    io << ' '
                    io << npc.y
                    io << ' '
                    io << npc.z
                    io << "\">Go</a></td></tr>"
                    counter += 1
                  else
                    skipped += 1
                  end
                end
              end

              io << "<tr><td>Skipped:</td><td>"
              io << skipped
              io << "</td></tr></table></body></html>"
            end

            ms = NpcHtmlMessage.new
            ms.html = html
            pc.send_packet(ms)
          else
            pc.send_message("Cannot find instance #{instance}")
          end
        else
          pc.send_message("Invalid instance number.")
        end
      rescue
        pc.send_message("Usage #instance_spawns <instance_number>")
      end
    elsif command.starts_with?("admin_unspawnall")
      Broadcast.to_all_online_players(SystemMessage.npc_server_not_operating)
      RaidBossSpawnManager.clean_up
      DayNightSpawnManager.clean_up
      L2World.delete_visible_npc_spawns
      AdminData.broadcast_message_to_gms("NPC unspawn completed")
    elsif command.starts_with?("admin_spawnday")
      DayNightSpawnManager.spawn_day_creatures
    elsif command.starts_with?("admin_spawnnight")
      DayNightSpawnManager.spawn_night_creatures
    elsif command.starts_with?("admin_respawnall", "admin_spawn_reload")
      # make sure all spawns are deleted
      RaidBossSpawnManager.clean_up
      DayNightSpawnManager.clean_up
      L2World.delete_visible_npc_spawns
      # now respawn all
      NpcData.load
      SpawnTable.load
      RaidBossSpawnManager.load
      AutoSpawnHandler.reload
      SevenSigns.instance.spawn_seven_signs_npc
      warn "Reloading scripts is not supported."
      # QuestManager.reload_all_scripts
      AdminData.broadcast_message_to_gms("NPC Respawn completed")
    elsif command.starts_with?("admin_spawn_monster", "admin_spawn")
      st = command.split
      begin
        cmd = st.shift
        id = st.shift
        respawn_time = 0
        mob_count = 1
        unless st.empty?
          mob_count = st.shift.to_i
        end
        unless st.empty?
          respawn_time = st.shift.to_i
        end
        if cmd.casecmp?("admin_spawn_once")
          spawn_monster(pc, id, respawn_time, mob_count, false)
        else
          spawn_monster(pc, id, respawn_time, mob_count, true)
        end
      rescue
        AdminHtml.show_admin_html(pc, "spawns.htm")
      end
    elsif command.starts_with?("admin_list_spawns", "admin_list_positions")
      npc_id = 0
      teleport_index = -1
      begin
        # admin_list_spawns x[xxxx] x[xx]
        params = command.split
        if params[1].num?
          npc_id = params[1].to_i
        else
          params[1] = params[1].tr("_", " ")
          unless template = NpcData.get_template_by_name(params[1])
            raise "No template with name #{params[1]}"
          end
          npc_id = template.id
        end
        if params.size > 2
          teleport_index = params[2].to_i
        end
      rescue
        pc.send_message("Command format is //list_spawns <npc_id|npc_name> [tele_index]")
      end
      if command.starts_with?("admin_list_positions")
        find_npc_instances(pc, npc_id, teleport_index, true)
      else
        find_npc_instances(pc, npc_id, teleport_index, false)
      end
    end

    true
  end

  private def find_npc_instances(pc, npc_id, teleport_index, show_position)
    i = 0
    SpawnTable.get_spawns(npc_id).each do |sp|
      i &+= 1
      npc = sp.last_spawn
      if teleport_index > -1
        if teleport_index == i
          if show_position && npc
            pc.tele_to_location(npc.location, true)
          else
            pc.tele_to_location(sp.location, true)
          end
        end
      else
        if show_position && npc
          pc.send_message("#{i} - #{sp.template.name} (#{sp}): #{npc.x} #{npc.y} #{npc.z}")
        else
          pc.send_message("#{i} - #{sp.template.name} (#{sp}): #{sp.x} #{sp.y} #{sp.z}")
        end
      end
    end

    if i == 0
      pc.send_message("#{self.class.simple_name}: No current spawns found.")
    end
  end

  private def print_spawn(target, type)
    i = target.id
    x = target.spawn.x
    y = target.spawn.y
    z = target.spawn.z
    h = target.spawn.heading
    case type
    when 0
      info { "('',1,#{i},#{x},#{y},#{z},0,0,#{h},60,0,0)," }
    when 1
      info { "<spawn npc_id='#{i}' x='#{x}' y='#{y}' z='#{z}' heading='#{h}' respawn='0' />" }
    when 2
      info { "{ #{i}, #{x}, #{y}, #{z}, #{h} }," }
    else
      # [automatically added else]
    end

  end

  private def spawn_monster(pc, mob_id, respawn_time, mob_count, permanent)
    target = pc.target || pc

    if mob_id.num?
      # First parameter was an ID number
      template = NpcData[mob_id.to_i]
    else
      # First parameter wasn't just numbers so go by name not ID
      template = NpcData.get_template_by_name(mob_id.sub('_', ' '))
    end

    unless template
      raise "No template for mob id #{mob_id}"
    end
    sp = L2Spawn.new(template)
    if Config.save_gmspawn_on_custom
      sp.custom = true
    end
    sp.x = target.x
    sp.y = target.y
    sp.z = target.z
    sp.amount = mob_count
    sp.heading = pc.heading
    sp.respawn_delay = respawn_time
    if pc.instance_id > 0
      sp.instance_id = pc.instance_id
      permanent = false
    else
      sp.instance_id = 0
    end
    # L2J TODO add checks for GrandBossSpawnManager
    if RaidBossSpawnManager.defined?(sp.id)
      pc.send_message("You cannot spawn another instance of #{template.name}.")
    else
      if template.type?("L2RaidBoss")
        sp.respawn_min_delay = 43200
        sp.respawn_max_delay = 129600
        RaidBossSpawnManager.add_new_spawn(sp, 0, template.base_hp_max.to_f, template.base_mp_max.to_f, permanent)
      else
        SpawnTable.add_new_spawn(sp, permanent)
        sp.init
      end
      unless permanent
        sp.stop_respawn
      end
      pc.send_message("Created #{template.name} on #{target.l2id}")
    end
  rescue
    pc.send_packet(SystemMessageId::TARGET_CANT_FOUND)
  end

  private def show_monsters(pc, level, from)
    mobs = NpcData.get_all_monsters_of_level(level)
    mob_count = mobs.size
    tb = String.build(500 + (mob_count * 80)) do |io|
      io << "<html><title>Spawn Monster:</title><body><p> Level : "
      io << level
      io << "<br>Total Npc's : "
      io << mob_count
      io << "<br>"

      i = from
      j = 0
      while i < mob_count && j < 50
        io << "<a action=\"bypass -h admin_spawn_monster "
        io << mobs[i].id
        io << "\">"
        io << mobs[i].name
        io << "</a><br1>"
        i &+= 1
        j &+= 1
      end

      if i == mob_count
        io << "<br><center><button value=\"Back\" action=\"bypass -h admin_show_spawns\" width=40 height=15 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></center></body></html>"
      else
        io << "<br><center><button value=\"Next\" action=\"bypass -h admin_spawn_index "
        io << level
        io << " "
        io << i
        io << "\" width=40 height=15 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"><button value=\"Back\" action=\"bypass -h admin_show_spawns\" width=40 height=15 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></center></body></html>"
      end
    end

    pc.send_packet(NpcHtmlMessage.new(tb))
  end

  private def show_npcs(pc, starting, from)
    mobs = NpcData.get_all_npc_starting_with(starting)
    mob_count = mobs.size
    tb = String.build(500 + (mob_count * 80)) do |io|
      io << "<html><title>Spawn Monster:</title><body><p> There are "
      io << mob_count
      io << " Npcs whose name starts with "
      io << starting
      io << ":<br>"

      i = from
      j = 0
      while i < mob_count && j < 50
        io << "<a action=\"bypass -h admin_spawn_monster "
        io << mobs[i].id
        io << "\">"
        io << mobs[i].name
        io << "</a><br1>"
        i &+= 1
        j &+= 1
      end

      if i == mob_count
        io << "<br><center><button value=\"Back\" action=\"bypass -h admin_show_npcs\" width=40 height=15 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></center></body></html>"
      else
        io << "<br><center><button value=\"Next\" action=\"bypass -h admin_npc_index "
        io << starting
        io << " "
        io << i
        io << "\" width=40 height=15 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"><button value=\"Back\" action=\"bypass -h admin_show_npcs\" width=40 height=15 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></center></body></html>"
      end
    end

    pc.send_packet(NpcHtmlMessage.new(tb))
  end

  def commands
    {
      "admin_show_spawns",
      "admin_spawn",
      "admin_spawn_monster",
      "admin_spawn_index",
      "admin_unspawnall",
      "admin_respawnall",
      "admin_spawn_reload",
      "admin_npc_index",
      "admin_spawn_once",
      "admin_show_npcs",
      "admin_spawnnight",
      "admin_spawnday",
      "admin_instance_spawns",
      "admin_list_spawns",
      "admin_list_positions",
      "admin_spawn_debug_menu",
      "admin_spawn_debug_print",
      "admin_spawn_debug_print_menu"
    }
  end
end
