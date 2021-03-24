module AdminCommandHandler::AdminGm
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    if command == "admin_gm" && pc.gm?
      AdminData.delete_gm(pc)
      pc.access_level = 0
      pc.send_message("You no longer have GM status.")
      info { "#{pc} turned his GM status off." }
    end

    true
  end

  def commands : Enumerable(String)
    {"admin_gm"}
  end
end
