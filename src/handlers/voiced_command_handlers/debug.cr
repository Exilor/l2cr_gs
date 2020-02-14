module VoicedCommandHandler::Debug
  extend self
  extend VoicedCommandHandler

  private COMMANDS = {"debug"}

  def use_voiced_command(cmd : String, pc : L2PcInstance, params : String) : Bool
    unless AdminData.has_access?(cmd, pc.access_level)
      return false
    end

    if cmd.casecmp?(COMMANDS[0])
      if pc.debugger?
        pc.debugger = nil
        pc.send_message("Debugging disabled.")
      else
        pc.debugger = pc
        pc.send_message("Debugging enabled.")
      end
    end

    true
  end

  def commands : Indexable(String)
    COMMANDS
  end
end
