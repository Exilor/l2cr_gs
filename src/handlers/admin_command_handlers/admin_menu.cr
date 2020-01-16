module AdminCommandHandler::AdminMenu
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    if command == "admin_char_manage"
      show_main_page(pc)
    elsif command.starts_with?("admin_teleport_character_to_menu")
      data = command.split
      if data.size == 5
        player_name = data[1]

        if player = L2World.get_player(player_name)
          teleport_character(player, Location.new(data[2].to_i, data[3].to_i, data[4].to_i), pc, "A GM teleported you.")
        end
      end
      show_main_page(pc)
    elsif command.starts_with?("admin_recall_char_menu")
      begin
        target_name = command.from(23)
        player = L2World.get_player(target_name)
        teleport_character(player, pc.location, pc, "A GM teleported you.")
      rescue e
        warn e
      end
    elsif command.starts_with?("admin_recall_party_menu")
      begin
        target_name = command.from(24)
        unless player = L2World.get_player(target_name)
          pc.send_packet(SystemMessageId::INCORRECT_TARGET)
          return true
        end
        unless party = player.party
          pc.send_message("#{player.name} is not in a party.")
          teleport_character(player, pc.location, pc, "A GM teleported you.")
          return true
        end
        party.members.each do |pm|
          teleport_character(pm, pc.location, pc, "Your party is being teleported by a GM.")
        end
      rescue e
        warn e
      end
    elsif command.starts_with?("admin_recall_clan_menu")
      begin
        target_name = command.from(23)
        unless player = L2World.get_player(target_name)
          pc.send_packet(SystemMessageId::INCORRECT_TARGET)
          return true
        end
        unless clan = player.clan
          pc.send_message("#{player.name} is not in a clan.")
          teleport_character(player, pc.location, pc, "A GM teleported you.")
          return true
        end

        clan.each_online_player do |member|
          teleport_character(member, pc.location, pc, "Your clan is being teleported by a GM.")
        end
      rescue e
        warn e
      end
    elsif command.starts_with?("admin_goto_char_menu")
      begin
        target_name = command.from(21)
        player = L2World.get_player(target_name).not_nil!
        pc.instance_id = player.instance_id
        teleport_to_character(pc, player)
      rescue e
        warn e
      end
    elsif command == "admin_kill_menu"
      handle_kill(pc)
    elsif command.starts_with?("admin_kick_menu")
      st = command.split
      if st.size > 1
        st.shift
        player = st.shift
        if plyr = L2World.get_player(player)
          plyr.logout
          text = "You kicked #{plyr.name} from the game."
        else
          text = "Player #{player} not found in the game."
        end
        pc.send_message(text)
      end
      show_main_page(pc)
    elsif command.starts_with?("admin_ban_menu")
      st = command.split
      if st.size > 1
        sub_cmd = "admin_ban_char"
        unless AdminData.has_access?(sub_cmd, pc.access_level)
          pc.send_message("You are not allowed to use this command.")
          warn { "Player #{pc.name} tried to use admin command #{sub_cmd}, but has no access to it." }
          return false
        end
        ach = AdminCommandHandler[sub_cmd].not_nil!
        ach.use_admin_command(sub_cmd + command.from(14), pc)
      end
      show_main_page(pc)
    elsif command.starts_with?("admin_unban_menu")
      st = command.split
      if st.size > 1
        sub_cmd = "admin_unban_char"
        unless AdminData.has_access?(sub_cmd, pc.access_level)
          pc.send_message("You are not allowed to use this command.")
          warn { "Player #{pc.name} tried to use admin command #{sub_cmd}, but has no access to it." }
          return false
        end
        ach = AdminCommandHandler[sub_cmd].not_nil!
        ach.use_admin_command(sub_cmd + command.from(16), pc)
      end
      show_main_page(pc)
    end

    true
  end

  private def handle_kill(pc, player = nil)
    obj = pc.target
    target = obj.as?(L2Character)
    filename = "main_menu.htm"
    if player
      if plyr = L2World.get_player(player)
        target = plyr
        pc.send_message("You killed #{plyr.name}")
      end
    end
    if target
      if target.is_a?(L2PcInstance)
        target.reduce_current_hp(target.max_hp.to_f + target.max_cp + 1, pc, nil)
        filename = "charmanage.htm"
      elsif Config.champion_enable && target.champion?
        target.reduce_current_hp((target.max_hp.to_f * Config.champion_hp) + 1, pc, nil)
      else
        target.reduce_current_hp(target.max_hp.to_f + 1, pc, nil)
      end
    else
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
    end
    AdminHtml.show_admin_html(pc, filename)
  end

  private def teleport_character(player, loc, pc, message)
    if player
      player.send_message(message)
      player.tele_to_location(loc, true)
    end
    show_main_page(pc)
  end

  private def teleport_to_character(pc, target)
    if target.is_a?(L2PcInstance)
      player = target
    else
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      return
    end
    if player.l2id == pc.l2id
      player.send_packet(SystemMessageId::CANNOT_USE_ON_YOURSELF)
    else
      pc.instance_id = player.instance_id
      pc.tele_to_location(player.location, true)
      pc.send_message("You're teleporting yourself to player #{player.name}")
    end
    show_main_page(pc)
  end

  private def show_main_page(pc)
    AdminHtml.show_admin_html(pc, "charmanage.htm")
  end

  def commands
    {
      "admin_char_manage",
      "admin_teleport_character_to_menu",
      "admin_recall_char_menu",
      "admin_recall_party_menu",
      "admin_recall_clan_menu",
      "admin_goto_char_menu",
      "admin_kick_menu",
      "admin_kill_menu",
      "admin_ban_menu",
      "admin_unban_menu"
    }
  end
end
