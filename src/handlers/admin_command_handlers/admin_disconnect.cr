module AdminCommandHandler::AdminDisconnect
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    if command == commands[0]
      disconnect_character(pc)
    end

    true
  end

  private def disconnect_character(pc)
    return unless target = pc.target.as?(L2PcInstance)

    if target == pc
      pc.send_message("You cannot log out your own character.")
    else
      pc.send_message("Player #{target.name} disconnected from server.")
      target.logout
    end
  end

  def commands : Enumerable(String)
    {"admin_character_disconnect"}
  end
end
