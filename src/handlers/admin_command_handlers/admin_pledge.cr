module AdminCommandHandler::AdminPledge
  extend self
  extend AdminCommandHandler

  def use_admin_command(command : String, pc : L2PcInstance) : Bool
    unless player = pc.target.as?(L2PcInstance)
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      show_main_page(pc)
      return false
    end

    name = player.name

    if command.starts_with?("admin_pledge")
      st = command.split
      begin
        st.shift
        action = st.shift # create|info|dismiss|setlevel|rep
        parameter = st.shift # clanname|nothing|nothing|level|rep_points
      rescue e
        warn e
        # TODO: Send some message.
        return false
      end
      if action == "create"
        cet = player.clan_create_expiry_time
        player.clan_create_expiry_time = 0
        if clan = ClanTable.create_clan(player, parameter)
          pc.send_message("Clan #{parameter} created. Leader: #{player}")
        else
          player.clan_create_expiry_time = cet
          pc.send_message("There was a problem while creating the clan.")
        end
      elsif !player.clan_leader?
        sm = SystemMessage.s1_is_not_a_clan_leader
        sm.add_string(name)
        pc.send_packet(sm)
        show_main_page(pc)
        return false
      elsif action == "dismiss"
        ClanTable.destroy_clan(player.clan_id)
        if player.clan
          pc.send_message("There was a problem while destroying the clan.")
        else
          pc.send_message("Clan disbanded.")
        end
      elsif action == "info"
        pc.send_packet(GMViewPledgeInfo.new(player.clan.not_nil!, player))
      elsif parameter.nil?
        pc.send_message("Usage: #pledge <setlevel|rep> <number>")
      elsif action == "setlevel"
        level = parameter.to_i
        clan = player.clan.not_nil!
        if level.between?(0, 11)
          clan.change_level(level)
          pc.send_message("You set level #{level} for clan #{clan.name}")
        else
          pc.send_message("Level incorrect.")
        end
      elsif action.starts_with?("rep")
        begin
          points = parameter.to_i
          clan = player.clan.not_nil!
          if clan.level < 5
            pc.send_message("Only clans of level 5 or above may receive reputation points.")
            show_main_page(pc)
            return false
          end
          clan.add_reputation_score(points, true)
          if points > 0
            msg = "You add #{points.abs} points to #{clan.name}'s reputation. Their current score is #{clan.reputation_score}"
          else
            msg = "You remove #{points.abs} points from #{clan.name}'s reputation. Their current score is #{clan.reputation_score}"
          end
          pc.send_message(msg)
        rescue
          pc.send_message("Usage: #pledge <rep> <number>")
        end
      end
    end

    show_main_page(pc)
    true
  end

  private def show_main_page(pc)
    AdminHtml.show_admin_html(pc, "game_menu.htm")
  end

  def commands : Enumerable(String)
    {"admin_pledge"}
  end
end
