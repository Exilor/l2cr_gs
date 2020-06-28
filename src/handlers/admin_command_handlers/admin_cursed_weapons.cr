module AdminCommandHandler::AdminCursedWeapons
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    cwm = CursedWeaponsManager
    id = 0

    st = command.split
    st.shift

    if command.starts_with?("admin_cw_info")
      if !command.includes?("menu")
        pc.send_message("====== Cursed Weapons: ======")
        cwm.cursed_weapons.each do |cw|
          pc.send_message("> #{cw.name} (#{cw.item_id})")
          if cw.activated?
            pl = cw.player?
            tmp = pl ? pl.name : "nil"
            pc.send_message("  Player holding: #{tmp}")
            pc.send_message("    Player karma: #{cw.player_karma}")
            pc.send_message("    Time Remaining: #{cw.time_left // 60000} min.")
            pc.send_message("    Kills : #{cw.nb_kills}")
          elsif cw.dropped?
            pc.send_message("  Lying on the ground.")
            pc.send_message("    Time Remaining: #{cw.time_left // 60000} min.")
            pc.send_message("    Kills : #{cw.nb_kills}")
          else
            pc.send_message("  Don't exist in the world.")
          end
          pc.send_packet(SystemMessageId::FRIEND_LIST_FOOTER)
        end
      else
        msg = String::Builder.new
        admin_reply = NpcHtmlMessage.new
        admin_reply.set_file(pc, "data/html/admin/cwinfo.htm")
        cwm.cursed_weapons.each do |cw|
          item_id = cw.item_id

          msg << "<table width=270><tr><td>Name:</td><td>"
          msg << cw.name
          msg << "</td></tr>"

          if cw.activated?
            pl = cw.player?
            msg << "<tr><td>Wielder:</td><td>"
            msg << (pl.nil? ? "nil" : pl.name)
            msg << "</td></tr><tr><td>Karma:</td><td>"
            msg << cw.player_karma
            msg << "</td></tr><tr><td>Kills:</td><td>"
            msg << cw.player_pk_kills
            msg << "/"
            msg << cw.nb_kills
            msg << "</td></tr><tr><td>Time remaining:</td><td>"
            msg << (cw.time_left // 60000)
            msg << " min.</td></tr><tr><td><button value=\"Remove\" action=\"bypass -h admin_cw_remove "
            msg << item_id
            msg << "\" width=73 height=21 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td><td><button value=\"Go\" action=\"bypass -h admin_cw_goto "
            msg << item_id
            msg << "\" width=73 height=21 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td></tr>"
          elsif cw.dropped?
            msg << "<tr><td>Position:</td><td>Lying on the ground</td></tr><tr><td>Time remaining:</td><td>"
            msg << (cw.time_left // 60000)
            msg << " min.</td></tr><tr><td>Kills:</td><td>"
            msg << cw.nb_kills
            msg << "</td></tr><tr><td><button value=\"Remove\" action=\"bypass -h admin_cw_remove "
            msg << item_id
            msg << "\" width=73 height=21 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td><td><button value=\"Go\" action=\"bypass -h admin_cw_goto "
            msg << item_id
            msg << "\" width=73 height=21 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td></tr>"
          else
            msg << "<tr><td>Position:</td><td>Doesn't exist.</td></tr><tr><td><button value=\"Give to Target\" action=\"bypass -h admin_cw_add "
            msg << item_id
            msg << "\" width=130 height=21 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td><td></td></tr>"
          end

          msg << "</table><br>"
        end
        admin_reply["%cwinfo%"] = msg
        pc.send_packet(admin_reply)
      end
    elsif command.starts_with?("admin_cw_reload")
      cwm.reload
    else
      begin
        parameter = st.shift
        if parameter.number?
          id = parameter.to_i
        else
          parameter = parameter.sub('_', ' ')
          cwm.cursed_weapons.each do |cwp|
            if cwp.name.downcase.includes?(parameter.downcase)
              id = cwp.item_id
              break
            end
          end
        end
        cw = cwm.get_cursed_weapon(id)
      rescue
        pc.send_message("Usage: #cw_remove|#cw_goto|#cw_add <item_id|name>")
      end

      unless cw
        pc.send_message("Unknown cursed weapon ID.")
        return false
      end

      if command.starts_with?("admin_cw_remove ")
        cw.end_of_life
      elsif command.starts_with?("admin_cw_goto ")
        cw.go_to(pc)
      elsif command.starts_with?("admin_cw_add")
        if cw.active?
          pc.send_message("This cursed weapon is already active.")
        else
          target = pc.target
          if target.is_a?(L2PcInstance)
            target.add_item("AdminCursedWeaponAdd", id, 1, target, true)
          else
            pc.add_item("AdminCursedWeaponAdd", id, 1, pc, true)
          end
          cw.end_time = Time.ms + (cw.duration * 60000)
          cw.reactivate
        end
      else
        pc.send_message("Unknown command.")
      end
    end

    true
  end

  def commands
    {
      "admin_cw_info",
      "admin_cw_remove",
      "admin_cw_goto",
      "admin_cw_reload",
      "admin_cw_add",
      "admin_cw_info_menu"
    }
  end
end
