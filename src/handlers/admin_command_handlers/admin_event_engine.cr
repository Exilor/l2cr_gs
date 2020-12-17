module AdminCommandHandler::AdminEventEngine
  extend self
  extend AdminCommandHandler

  @@temp_buffer = ""
  @@temp_name = ""
  @@npcs_deleted = false

  def use_admin_command(command, pc)
    st = command.split
    actual_cmd = st.shift

    begin
      if actual_cmd == "admin_event"
        if L2Event.event_state.off?
          show_main_page(pc)
        else
          show_event_control(pc)
        end
      elsif actual_cmd == "admin_event_new"
        show_new_event_page(pc)
      elsif actual_cmd.starts_with?("admin_add")
        # There is an exception here for not using the ST. We use spaces (ST delim) for the event info.
        @@temp_buffer += command.from(10)
        show_new_event_page(pc)
      elsif actual_cmd.starts_with?("admin_event_see")
        # There is an exception here for not using the ST. We use spaces (ST delim) for the event name.
        event_name = command.from(16)
        begin
          admin_reply = NpcHtmlMessage.new

          File.open("#{Config.datapack_root}/data/events/#{event_name}") do |f|
            admin_reply.set_file("en", "data/html/mods/EventEngine/Participation.htm")
            admin_reply["%eventName%"] = event_name
            admin_reply["%eventCreator%"] = f.gets.not_nil!
            admin_reply["%eventInfo%"] = f.gets.not_nil!
            admin_reply["npc_%objectId%_event_participate"] = "admin_event" # Weird, but nice hack, isnt it? :)
            admin_reply["button value=\"Participate\""] = "button value=\"Back\""
            pc.send_packet(admin_reply)
          end
        rescue e
          warn e
        end
      elsif actual_cmd.starts_with?("admin_event_del")
        # There is an exception here for not using the ST. We use spaces (ST delim) for the event name.
        event_name = command.from(16)
        File.delete("#{Config.datapack_root}/data/events/#{event_name}")
        show_main_page(pc)
      elsif actual_cmd.starts_with?("admin_event_name")
        # There is an exception here for not using the ST. We use spaces (ST delim) for the event name.
        @@temp_name += command.from(17)
        show_new_event_page(pc)
      elsif actual_cmd.casecmp?("admin_delete_buffer")
        @@temp_buffer = ""
        show_new_event_page(pc)
      elsif actual_cmd.starts_with?("admin_event_store")
        begin
          File.open("#{Config.datapack_root}/data/events/#{@@temp_name}", "w") do |f|
            f.puts(pc.name)
            f.puts(@@temp_buffer)
          end
        rescue e
          warn e
        end

        @@temp_buffer = ""
        @@temp_name = ""
        show_main_page(pc)
      elsif actual_cmd.starts_with?("admin_event_set")
        # There is an exception here for not using the ST. We use spaces (ST delim) for the event name.
        L2Event.event_name = command.from(16)
        show_event_parameters(pc, 2)
      elsif actual_cmd.starts_with?("admin_event_change_teams_number")
        show_event_parameters(pc, st.shift.to_i)
      elsif actual_cmd.starts_with?("admin_event_panel")
        show_event_control(pc)
      elsif actual_cmd.starts_with?("admin_event_announce")
        L2Event.npc_id = st.shift.to_i
        L2Event.teams_number = st.shift.to_i
        temp = " "
        temp2 = ""
        until st.empty?
          temp += st.shift + " "
        end

        st = temp.split('-')

        i = 1

        until st.empty?
          temp2 = st.shift
          unless temp2 == " "
            L2Event::TEAM_NAMES[i &+= 1] = temp2[1...temp2.size &- 1]
          end
        end

        pc.send_message(L2Event.start_event_participation)
        Broadcast.to_all_online_players(pc.name + " has started an event. You will find a participation NPC somewhere around you.")

        sound = Music::B03_F.packet
        pc.send_packet(sound)
        pc.broadcast_packet(sound)

        admin_reply = NpcHtmlMessage.new

        reply_msg = "<html><title>[ EVENT ENGINE ]</title><body><br><center>The event <font color=\"LEVEL\">#{L2Event.event_name}</font> has been announced, now you can type #event_panel to see the event panel control</center><br></body></html>"
        admin_reply.html = reply_msg
        pc.send_packet(admin_reply)
      elsif actual_cmd.starts_with?("admin_event_control_begin")
        # Starts the event and sends a message of the result
        pc.send_message(L2Event.start_event)
        show_event_control(pc)
      elsif actual_cmd.starts_with?("admin_event_control_finish")
        # Finishes the event and sends a message of the result
        pc.send_message(L2Event.finish_event)
      elsif actual_cmd.starts_with?("admin_event_control_teleport")
        until st.empty? # Every next ST should be a team number
          team_id = st.shift.to_i

          L2Event::TEAMS[team_id].each do |player|
            player.title = L2Event::TEAM_NAMES[team_id]
            player.tele_to_location(pc, true)
            player.instance_id = pc.instance_id
          end
        end
        show_event_control(pc)
      elsif actual_cmd.starts_with?("admin_event_control_sit")
        until st.empty? # Every next ST should be a team number
          # st.shift.to_i == team_id
          L2Event::TEAMS[st.shift.to_i].each do |player|
            unless es = player.event_status
              next
            end

            es.sit_forced = !es.sit_forced?
            if es.sit_forced?
              player.sit_down
            else
              player.stand_up
            end
          end
        end
        show_event_control(pc)
      elsif actual_cmd.starts_with?("admin_event_control_kill")
        until st.empty? # Every next ST should be a team number
          L2Event::TEAMS[st.shift.to_i].each do |player|
            player.reduce_current_hp(player.max_hp.to_f + player.max_cp + 1, pc, nil)
          end
        end
        show_event_control(pc)
      elsif actual_cmd.starts_with?("admin_event_control_res")
        until st.empty? # Every next ST should be a team number
          L2Event::TEAMS[st.shift.to_i].each do |player|
            if player.alive?
              next
            end
            player.restore_exp(100.0)
            player.do_revive
            player.set_current_hp_mp(player.max_hp.to_f, player.max_mp.to_f)
            player.current_cp = player.max_cp.to_f
          end
        end
        show_event_control(pc)
      elsif actual_cmd.starts_with?("admin_event_control_poly")
        team_id = st.shift.to_i
        poly_ids = st

        L2Event::TEAMS[team_id].each do |player|
          player.poly.set_poly_info("npc", poly_ids.sample)
          player.tele_to_location(player, true)
          info1 = CharInfo.new(player)
          player.broadcast_packet(info1)
          info2 = UserInfo.new(player)
          player.send_packet(info2)
          player.broadcast_packet(ExBrExtraUserInfo.new(player))
        end
        show_event_control(pc)
      elsif actual_cmd.starts_with?("admin_event_control_unpoly")
        until st.empty? # Every next ST should be a team number
          L2Event::TEAMS[st.shift.to_i].each do |player|
            player.poly.set_poly_info(nil, "1")
            player.decay_me
            player.spawn_me(*player.xyz)
            info1 = CharInfo.new(player)
            player.broadcast_packet(info1)
            info2 = UserInfo.new(player)
            player.send_packet(info2)
            player.broadcast_packet(ExBrExtraUserInfo.new(player))
          end
        end
        show_event_control(pc)
      elsif actual_cmd.starts_with?("admin_event_control_transform")
        team_id = st.shift.to_i
        trans_ids = Slice.new(st.size, 0)
        i = 0
        until st.empty? # Every next ST should be a transform ID
          trans_ids[i &+= 1] = st.shift.to_i
        end

        L2Event::TEAMS[team_id].each do |player|
          trans_id = trans_ids.sample
          unless TransformData.transform_player(trans_id, player)
            AdminData.broadcast_message_to_gms("EventEngine: Unknow transformation id: #{trans_id}")
          end
        end
        show_event_control(pc)
      elsif actual_cmd.starts_with?("admin_event_control_untransform")
        until st.empty? # Every next ST should be a team number
          L2Event::TEAMS[st.shift.to_i].each do |player|
            player.stop_transformation(true)
          end
        end
        show_event_control(pc)
      elsif actual_cmd.starts_with?("admin_event_control_kick")
        if !st.empty? # If has next token, it should be player name.
          until st.empty?
            if player = L2World.get_player(st.shift)
              L2Event.remove_and_reset_player(player)
            end
          end
        else
          if target = pc.target.as?(L2PcInstance)
            L2Event.remove_and_reset_player(target)
          end
        end
        show_event_control(pc)
      elsif actual_cmd.starts_with?("admin_event_control_prize")
        team_ids = Slice.new(st.size &- 2, 0)
        i = 0
        while st.size &- 2 > 0 # The last 2 tokens are used for "n" and "item id"
          team_ids[i &+= 1] = st.shift.to_i
        end

        n = st.shift.split(/\\*/)
        item_id = st.shift.to_i

        team_ids.each do |team_id|
          reward_team(pc, team_id, n[0].to_i, item_id, n.size == 2 ? n[1] : "")
        end
        show_event_control(pc)
      end
    rescue e
      warn e
      AdminData.broadcast_message_to_gms("EventEngine: Error! Possible blank boxes while executing a command which requires a value in the box?")
    end

    true
  end

  private def show_stored_events : String
    path = Config.datapack_root + "/data/events"
    if File.directory?(path)
      return "<font color=\"FF0000\">The directory '#{path}' is a file or is corrupted</font><br>"
    end

    unless File.file?(path)
      note = "<font color=\"FF0000\">The directory '#{path}' does not exist</font><br><font color=\"0099FF\">Trying to create it now...<br></font><br>"
      if (Dir.mkdir_p(path) rescue false)
        note += "<font color=\"006600\">The directory '#{path}' has been created</font><br>"
      else
        note += "<font color=\"FF0000\">The directory '#{path}' couldn't be created</font><br>"
        return note
      end
    end

    files = Dir.open(path).each_child.to_a
    result = String::Builder.new(files.size * 500)
    result << note
    result << "<table>"
    files.each do |file_name|
      result << "<tr><td align=center>"
      result << file_name
      result << " </td></tr><tr><td><table cellspacing=0><tr><td><button value=\"Select Event\" action=\"bypass -h admin_event_set "
      result << file_name
      result << "\" width=90 height=20 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td><td><button value=\"View Event\" action=\"bypass -h admin_event_see "
      result << file_name
      result << "\" width=90 height=20 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td><td><button value=\"Delete Event\" action=\"bypass -h admin_event_del "
      result << file_name
      result << "\" width=90 height=20 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td></tr></table></td></tr>"
      result << "<tr><td>&nbsp;</td></tr><tr><td>&nbsp;</td></tr>"
    end

    result << "</table>"

    result.to_s
  end

  def show_main_page(pc : L2PcInstance)
    admin_reply = NpcHtmlMessage.new

    reply_msg = "<html><title>[ EVENT ENGINE ]</title><body><br><center><button value=\"Create NEW event \" action=\"bypass -h admin_event_new\" width=150 height=32 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"><center><br><font color=LEVEL>Stored Events:</font><br></center>#{show_stored_events}</body></html>"
    admin_reply.html = reply_msg
    pc.send_packet(admin_reply)
  end

  def show_new_event_page(pc : L2PcInstance)
    admin_reply = NpcHtmlMessage.new
    reply_msg = String::Builder.new(500)
    reply_msg << "<html><title>[ EVENT ENGINE ]</title><body><br><br><center><font color=LEVEL>Event name:</font><br>"

    if @@temp_name.empty?
      reply_msg << "You can also use #event_name text to insert a new title" \
        "<center><multiedit var=\"name\" width=260 height=24> <button value=\"Set Event Name\" action=\"bypass -h admin_event_name $name\" width=120 height=20 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\">"
    else
      reply_msg << @@temp_name
    end

    reply_msg << "<br><br><font color=LEVEL>Event description:</font><br></center>"

    if @@temp_buffer.empty?
      reply_msg << "You can also use #add text to add text or #delete_buffer to remove the text."
    else
      reply_msg << @@temp_buffer
    end

    reply_msg << "<center><multiedit var=\"txt\" width=270 height=100> <button value=\"Add text\" action=\"bypass -h admin_add $txt\" width=120 height=20 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\">" \
      "<button value=\"Remove text\" action=\"bypass -h admin_delete_buffer\" width=120 height=20 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\">"

    unless @@temp_name.empty? && @@temp_buffer.empty?
      reply_msg << "<br><button value=\"Store Event Data\" action=\"bypass -h admin_event_store\" width=160 height=32 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\">"
    end

    reply_msg << "</center></body></html>"

    admin_reply.html = reply_msg.to_s
    pc.send_packet(admin_reply)
  end

  def show_event_parameters(pc : L2PcInstance, team_numbers : Int32)
    admin_reply = NpcHtmlMessage.new
    sb = String::Builder.new

    sb << "<html><body><title>[ EVENT ENGINE ]</title><br><center> Current event: <font color=\"LEVEL\">"
    sb << L2Event.event_name
    sb << "</font></center><br>INFO: To start an event, you must first set the number of teams, then type their names in the boxes and finally type the NPC ID that will be the event manager (can be any existing npc) next to the \"Announce Event!\" button.<br><table width=100%>" \
      "<tr><td><button value=\"Announce Event!\" action=\"bypass -h admin_event_announce $event_npcid "
    sb << team_numbers
    sb << " "
    i = 0
    while i &- 1 < team_numbers
      sb << "$event_teams_name"
      sb << i
      sb << " - "
      i &+= 1
    end
    sb << "\" width=140 height=32 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td>" \
      "<td><edit var=\"event_npcid\" width=100 height=20></td></tr>" \
      "<tr><td><button value=\"Set number of teams\" action=\"bypass -h admin_event_change_teams_number $event_teams_number\" width=140 height=32 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td>" \
      "<td><edit var=\"event_teams_number\" width=100 height=20></td></tr>" \
      "</table><br><center> <br><br>" \
      "<font color=\"LEVEL\">Teams' names:</font><br><table width=100% cellspacing=8>"
    i = 1
    while i &- 1 < team_numbers
      sb << "<tr><td align=center>Team #"
      sb << i
      sb << " name:</td><td><edit var=\"event_teams_name"
      sb << i
      sb << "\" width=150 height=15></td></tr>"
      i &+= 1
    end
    sb << "</table></body></html>"

    admin_reply.html = sb.to_s
    pc.send_packet(admin_reply)
  end

  private def show_event_control(pc)
    admin_reply = NpcHtmlMessage.new
    sb = String::Builder.new
    sb << "<html><title>[ EVENT ENGINE ]</title><body><br><center>Current event: <font color=\"LEVEL\">"
    sb << L2Event.event_name
    sb << "</font></center><br><table cellspacing=-1 width=280><tr><td align=center>Type the team ID(s) that will be affected by the commands. Commands with '*' work with only 1 team ID in the field, while '!' - none.</td></tr><tr><td align=center><edit var=\"team_number\" width=100 height=15></td></tr>" \
      "<tr><td>&nbsp;</td></tr><tr><td><table width=200>"
    unless @@npcs_deleted
      sb << "<tr><td><button value=\"Start!\" action=\"bypass -h admin_event_control_begin\" width=100 height=20 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td><td><font color=\"LEVEL\">Destroys all event npcs so no more people can't participate now on</font></td></tr>"
    end

    sb << "<tr><td>&nbsp;</td></tr>" \
      "<tr><td><button value=\"Teleport\" action=\"bypass -h admin_event_control_teleport $team_number\" width=100 height=20 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td><td><font color=\"LEVEL\">Teleports the specified team to your position</font></td></tr>" \
      "<tr><td>&nbsp;</td></tr><tr><td><button value=\"Sit/Stand\" action=\"bypass -h admin_event_control_sit $team_number\" width=100 height=20 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td><td><font color=\"LEVEL\">Sits/Stands up the team</font></td></tr>" \
      "<tr><td>&nbsp;</td></tr>" \
      "<tr><td><button value=\"Kill\" action=\"bypass -h admin_event_control_kill $team_number\" width=100 height=20 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td><td><font color=\"LEVEL\">Finish with the life of all the players in the selected team</font></td></tr>" \
      "<tr><td>&nbsp;</td></tr><tr><td><button value=\"Resurrect\" action=\"bypass -h admin_event_control_res $team_number\" width=100 height=20 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td><td><font color=\"LEVEL\">Resurrect Team's members</font></td></tr>" \
      "<tr><td>&nbsp;</td></tr>" \
      "<tr><td><table cellspacing=-1><tr><td><button value=\"Polymorph*\" action=\"bypass -h admin_event_control_poly $team_number $poly_id\" width=100 height=20 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td></tr><tr><td><edit var=\"poly_id\" width=98 height=15></td></tr></table></td>" \
      "<td><font color=\"LEVEL\">Polymorphs the team into the NPC with the ID specified. Multiple IDs result in randomly chosen one for each player.</font></td></tr>" \
      "<tr><td>&nbsp;</td></tr><tr><td><button value=\"UnPolymorph\" action=\"bypass -h admin_event_control_unpoly $team_number\" width=100 height=20 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td><td><font color=\"LEVEL\">Unpolymorph the team</font></td></tr>" \
      "<tr><td>&nbsp;</td></tr>" \
      "<tr><td><table cellspacing=-1><tr><td><button value=\"Transform*\" action=\"bypass -h admin_event_control_transform $team_number $transf_id\" width=100 height=20 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td></tr><tr><td><edit var=\"transf_id\" width=98 height=15></td></tr>" \
      "</table></td><td><font color=\"LEVEL\">Transforms the team into the transformation with the ID specified. Multiple IDs result in randomly chosen one for each player.</font></td></tr>" \
      "<tr><td>&nbsp;</td></tr><tr><td><button value=\"UnTransform\" action=\"bypass -h admin_event_control_untransform $team_number\" width=100 height=20 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td><td><font color=\"LEVEL\">Untransforms the team</font></td></tr>" \
      "<tr><td>&nbsp;</td></tr>" \
      "<tr><td><table cellspacing=-1><tr><td><button value=\"Give Item\" action=\"bypass -h admin_event_control_prize $team_number $n $id\" width=100 height=20 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td></tr></table><table><tr><td width=32>Num</td><td><edit var=\"n\" width=60 height=15></td></tr>" \
      "<tr><td>ID</td><td><edit var=\"id\" width=60 height=15></td></tr></table></td><td><font color=\"LEVEL\">Give the specified item id to every single member of the team, you can put 5*level, 5*kills or 5 in the number field for example</font></td></tr><tr><td>&nbsp;</td></tr>" \
      "<tr><td><table cellspacing=-1><tr><td><button value=\"Kick Player\" action=\"bypass -h admin_event_control_kick $player_name\" width=100 height=20 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td></tr><tr><td><edit var=\"player_name\" width=98 height=15></td></tr></table></td>" \
      "<td><font color=\"LEVEL\">Kicks the specified player(s) from the event. Blank field kicks target.</font></td></tr><tr><td>&nbsp;</td></tr>" \
      "<tr><td><button value=\"End!\" action=\"bypass -h admin_event_control_finish\" width=100 height=20 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td><td><font color=\"LEVEL\">Will finish the event teleporting back all the players</font></td></tr>" \
      "<tr><td>&nbsp;</td></tr></table></td></tr></table></body></html>"

    admin_reply.html = sb.to_s
    pc.send_packet(admin_reply)
  end

  private def reward_team(pc, team, n, id, type)
    num = n
    L2Event::TEAMS[team].each do |player|
      if type.casecmp?("level")
        num = n * player.level
      elsif type.casecmp?("kills") && (es = player.event_status)
        num = n * es.kills.size
      else
        num = n
      end

      player.add_item("Event", id, num.to_i64, pc, true)

      admin_reply = NpcHtmlMessage.new
      admin_reply.html = "<html><body> CONGRATULATIONS! You should have been rewarded. </body></html>"
      player.send_packet(admin_reply)
    end
  end

  def commands
    {
      "admin_event",
      "admin_event_new",
      "admin_event_choose",
      "admin_event_store",
      "admin_event_set",
      "admin_event_change_teams_number",
      "admin_event_announce",
      "admin_event_panel",
      "admin_event_control_begin",
      "admin_event_control_teleport",
      "admin_add",
      "admin_event_see",
      "admin_event_del",
      "admin_delete_buffer",
      "admin_event_control_sit",
      "admin_event_name",
      "admin_event_control_kill",
      "admin_event_control_res",
      "admin_event_control_poly",
      "admin_event_control_unpoly",
      "admin_event_control_transform",
      "admin_event_control_untransform",
      "admin_event_control_prize",
      "admin_event_control_chatban",
      "admin_event_control_kick",
      "admin_event_control_finish"
    }
  end
end
