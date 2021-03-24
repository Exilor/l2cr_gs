module AdminCommandHandler::AdminAdmin
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    case
    when command.starts_with?("admin_admin")
      show_main_page(pc, command)
    when command == "admin_config_server"
      show_config_page(pc)
    when command.starts_with?("admin_gmliston")
      AdminData.show_gm(pc)
      pc.send_message("Registered into gm list")
      AdminHtml.show_admin_html(pc, "gm_menu.htm")
    when command.starts_with?("admin_gmlistoff")
      AdminData.hide_gm(pc)
      pc.send_message("Removed from gm list")
      AdminHtml.show_admin_html(pc, "gm_menu.htm")
    when command.starts_with?("admin_silence")
      if pc.silence_mode?
        pc.silence_mode = false
        pc.send_packet(SystemMessageId::MESSAGE_ACCEPTANCE_MODE)
      else
        pc.silence_mode = true
        pc.send_packet(SystemMessageId::MESSAGE_REFUSAL_MODE)
      end

      AdminHtml.show_admin_html(pc, "gm_menu.htm")
    when command.starts_with?("admin_saveolymp")
      Olympiad.instance.save_olympiad_status
      pc.send_message("olympiad system saved.")
    when command.starts_with?("admin_endolympiad")
      begin
        Olympiad.instance.manual_select_heroes
      rescue e
        error "An error occured while ending olympiad:"
        error e
      else
        pc.send_message("Heroes formed.")
      end
    when command.starts_with?("admin_sethero")
      unless target = pc.target
        pc.send_packet(SystemMessageId::INCORRECT_TARGET)
        return false
      end

      target = target.as?(L2PcInstance) || pc
      target.hero = !target.hero?
      target.broadcast_user_info
    when command.starts_with?("admin_givehero")
      unless pc.target
        pc.send_packet(SystemMessageId::INCORRECT_TARGET)
        return false
      end

      target = pc.target.as?(L2PcInstance) || pc
      if Hero.hero?(target.l2id)
        pc.send_message("This player has already claimed the hero status.")
        return false
      end

      unless Hero.unclaimed_hero?(target.l2id)
        pc.send_message("This player cannot claim the hero status.")
        return false
      end
      Hero.claim_hero(target)
    when command.starts_with?("admin_diet")
      pc.diet_mode = command.ends_with?("on")
      pc.send_message(pc.diet_mode? ? "Diet mode on" : "Diet mode off")
      pc.refresh_overloaded
      AdminHtml.show_admin_html(pc, "gm_menu.htm")
    when command.starts_with?("admin_tradeoff")
      pc.trade_refusal = command.ends_with?("on")
      if pc.trade_refusal?
        pc.send_message("Trade refusal enabled")
      else
        pc.send_message("Trade refusal disabled")
      end
      AdminHtml.show_admin_html(pc, "gm_menu.htm")
    when command.starts_with?("admin_setconfig")
      st = command.split
      st.shift?
      begin
        p_name = st.shift
        p_value = st.shift
        if Config.set_parameter_value(p_name, p_value)
          pc.send_message("Config parameter #{p_name} set to #{p_value}")
        else
          pc.send_message("Invalid parameter")
        end
      rescue e
        pc.send_message "Usage: //setconfig <parameter> <value>"
      ensure
        show_config_page(pc)
      end
    when command.starts_with?("admin_set")
      st = command.split
      cmd = st.shift.split('_')
      begin
        parameter = st.shift.split('=')
        p_name = parameter[0].strip
        p_value = parameter[1].strip
        if Config.set_parameter_value(p_name, p_value)
          pc.send_message("parameter #{p_name} succesfully set to #{p_value}")
        else
          pc.send_message("Invalid parameter")
        end
      rescue e
        if cmd.size == 2
          pc.send_message("Usage: //set parameter=value")
        else
          warn e
        end
      ensure
        if cmd.size == 3
          if cmd[2].casecmp?("mod")
            AdminHtml.show_admin_html(pc, "mods_menu.htm")
          end
        end
      end
    when command.starts_with?("admin_gmon")
      # nothing
    end

    true
  end

  private def show_main_page(pc, command)
    file_name =
    case command.from(11).to_i { 0 }
    when 1 then "main_menu.htm"
    when 2 then "game_menu.htm"
    when 3 then "effects_menu.htm"
    when 4 then "server_menu.htm"
    when 5 then "mods_menu.htm"
    when 6 then "char_menu.htm"
    when 7 then "gm_menu.htm"
    else "main_menu.htm"
    end

    AdminHtml.show_admin_html(pc, file_name)
  end

  private def show_config_page(pc)
    admin_reply = NpcHtmlMessage.new
    msg = <<-HTML
      <html><title>Config</title><body>
      <center><table width=270><tr><td width=60><button value=\"Main\" action=\"bypass -h admin_admin\" width=60 height=25 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td><td width=150>Config Server Panel</td><td width=60><button value=\"Back\" action=\"bypass -h admin_admin4\" width=60 height=25 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td></tr></table></center><br>
      <center><table width=260><tr><td width=140></td><td width=40></td><td width=40></td></tr>
      <tr><td><font color=\"00AA00\">Drop:</font></td><td></td><td></td></tr>
      <tr><td><font color=\"LEVEL\">Rate EXP</font> = #{Config.rate_xp}</td><td><edit var=\"param1\" width=40 height=15></td><td><button value=\"Set\" action=\"bypass -h admin_setconfig RateXp $param1\" width=40 height=25 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td></tr>
      <tr><td><font color=\"LEVEL\">Rate SP</font> = #{Config.rate_sp}</td><td><edit var=\"param2\" width=40 height=15></td><td><button value=\"Set\" action=\"bypass -h admin_setconfig RateSp $param2\" width=40 height=25 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td></tr>
      <tr><td><font color=\"LEVEL\">Rate Drop Spoil</font> = #{Config.rate_corpse_drop_chance_multiplier}</td><td><edit var=\"param4\" width=40 height=15></td><td><button value=\"Set\" action=\"bypass -h admin_setconfig RateDropSpoil $param4\" width=40 height=25 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td></tr>
      <tr><td width=140></td><td width=40></td><td width=40></td></tr>
      <tr><td><font color=\"00AA00\">Enchant:</font></td><td></td><td></td></tr>
      <tr><td><font color=\"LEVEL\">Enchant Element Stone</font> = #{Config.enchant_chance_element_stone}</td><td><edit var=\"param8\" width=40 height=15></td><td><button value=\"Set\" action=\"bypass -h admin_setconfig EnchantChanceElementStone $param8\" width=40 height=25 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td></tr>
      <tr><td><font color=\"LEVEL\">Enchant Element Crystal</font> = #{Config.enchant_chance_element_crystal}</td><td><edit var=\"param9\" width=40 height=15></td><td><button value=\"Set\" action=\"bypass -h admin_setconfig EnchantChanceElementCrystal $param9\" width=40 height=25 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td></tr>
      <tr><td><font color=\"LEVEL\">Enchant Element Jewel</font> = #{Config.enchant_chance_element_jewel}</td><td><edit var=\"param10\" width=40 height=15></td><td><button value=\"Set\" action=\"bypass -h admin_setconfig EnchantChanceElementJewel $param10\" width=40 height=25 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td></tr>
      <tr><td><font color=\"LEVEL\">Enchant Element Energy</font> = #{Config.enchant_chance_element_energy}</td><td><edit var=\"param11\" width=40 height=15></td><td><button value=\"Set\" action=\"bypass -h admin_setconfig EnchantChanceElementEnergy $param11\" width=40 height=25 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td></tr>
      </table></body></html>
    HTML
    admin_reply.html = msg
    pc.send_packet(admin_reply)
  end

  def commands : Enumerable(String)
    {
      "admin_admin",
      "admin_admin1",
      "admin_admin2",
      "admin_admin3",
      "admin_admin4",
      "admin_admin5",
      "admin_admin6",
      "admin_admin7",
      "admin_gmliston",
      "admin_gmlistoff",
      "admin_silence",
      "admin_diet",
      "admin_tradeoff",
      "admin_set",
      "admin_set_mod",
      "admin_saveolymp",
      "admin_sethero",
      "admin_givehero",
      "admin_endolympiad",
      "admin_setconfig",
      "admin_config_server",
      "admin_gmon"
    }
  end
end
