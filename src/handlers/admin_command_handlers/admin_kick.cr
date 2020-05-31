module AdminCommandHandler::AdminKick
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    if command.starts_with?("admin_kick")
      st = command.split
      if st.size > 1
        st.shift
        player = st.shift
        if plyr = L2World.get_player(player)
          plyr.logout
          pc.send_message("You kicked #{plyr.name} from the game.")
        end
      end
    end
    if command.starts_with?("admin_kick_non_gm")
      count = 0
      L2World.players.each do |player|
        unless player.gm?
          count &+= 1
          player.logout
        end
      end
      pc.send_message("Kicked #{count} players")
    end

    true
  end

  def commands
    {
      "admin_kick",
      "admin_kick_non_gm"
    }
  end
end
