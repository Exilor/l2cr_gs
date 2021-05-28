module AdminCommandHandler::AdminSummon
  extend self
  extend AdminCommandHandler

  def use_admin_command(command : String, pc : L2PcInstance) : Bool
    id = 0
    count = 1
    data = command.split

    begin
      id = data[1].to_i
      if data.size > 2
        count = data[2].to_i
      end
    rescue
      pc.send_message("Incorrect format for command 'summon'")
    end

    if id < 1_000_000
      sub_command = "admin_create_item"
      unless AdminData.has_access?(sub_command, pc.access_level)
        pc.send_message("You don't have the access right to use this command.")
        warn { "Player #{pc} tried to use admin command '#{sub_command}' without enough access level." }
        return false
      end
      if ach = AdminCommandHandler[sub_command]
        ach.use_admin_command("#{sub_command} #{id} #{count}", pc)
      end
    else
      sub_command = "admin_spawn_once"
      unless AdminData.has_access?(sub_command, pc.access_level)
        pc.send_message("You don't have the access right to use this command.")
        warn { "Player #{pc} tried to use admin command '#{sub_command}' without enough access level." }
        return false
      end

      if ach = AdminCommandHandler[sub_command]
        id -= 1_000_000
        ach.use_admin_command("#{sub_command} #{id} #{count}", pc)
      end
    end

    true
  end

  def commands : Enumerable(String)
    {"admin_summon"}
  end
end
