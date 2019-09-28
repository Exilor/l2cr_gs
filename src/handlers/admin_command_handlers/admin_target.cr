module AdminCommandHandler::AdminTarget
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    if command.starts_with?("admin_target")
      handle_target(command, pc)
    end

    true
  end

  private def handle_target(command, pc)
    target_name = command.from(13)
    if player = L2World.get_player(target_name)
      player.on_action(pc)
    else
      pc.send_message("Player #{target_name} not found")
    end
  rescue
    pc.send_message("Invalid name")
  end

  def commands
    {"admin_target"}
  end
end
