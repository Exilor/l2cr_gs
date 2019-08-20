module AdminCommandHandler::AdminBBS
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    true
  end

  def commands
    {"admin_bbs"}
  end
end
