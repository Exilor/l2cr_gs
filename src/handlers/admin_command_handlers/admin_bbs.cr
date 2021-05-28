module AdminCommandHandler::AdminBBS
  extend self
  extend AdminCommandHandler

  def use_admin_command(command : String, pc : L2PcInstance) : Bool
    true
  end

  def commands : Enumerable(String)
    {"admin_bbs"}
  end
end
