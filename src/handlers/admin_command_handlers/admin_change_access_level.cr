module AdminCommandHandler::AdminChangeAccessLevel
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    parts = command.split
    if parts.size == 2
      begin
        lvl = parts[1].to_i
        if target = pc.target.as?(L2PcInstance)
          online_change(pc, target, lvl)
        else
          pc.send_packet(SystemMessageId::INCORRECT_TARGET)
        end
      rescue e
        pc.send_message("Usage: #changelvl <target_new_level> | <player_name> <new_level>")
      end
    elsif parts.size == 3
      name = parts[1]
      lvl = parts[2].to_i

      if player = L2World.get_player(name)
        online_change(pc, player, lvl)
      else
        begin
          sql = "UPDATE characters SET accesslevel=? WHERE char_name=?"
          count = GameDB.exec(sql, lvl, name)

          if count == 0
            pc.send_message("Character not found or access level unaltered.")
          else
            pc.send_message("Character's access level is now set to #{lvl}.")
          end
        rescue e
          pc.send_message("Database error while changing access level")
          debug e
        end
      end
    end

    true
  end

  private def online_change(pc, target, lvl)
    if lvl >= 0
      if AdminData.includes?(lvl)
        access_lvl = AdminData.get_access_level(lvl)
        target.access_level = lvl
        target.send_message("Your access level has been changed to #{access_lvl.name} (#{access_lvl.level}).")
        pc.send_message("#{target.name}'s access level has been changed to #{access_lvl.name} (#{access_lvl.level}).")
      else
        pc.send_message("Access level #{lvl} does not exist.")
      end
    else
      target.access_level = lvl
      target.send_message("Your character has been banned.")
      target.logout
    end
  end

  def commands
    {"admin_changelvl"}
  end
end
