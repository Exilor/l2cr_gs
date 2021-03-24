module BypassHandler::VoiceCommand
  extend self
  extend BypassHandler

  def use_bypass(command : String, pc : L2PcInstance, target : L2Character?) : Bool
    if command.size > 7 && command[6] == '.'
      if end_of_cmd = command.index(' ', 7)
        vc = command[7...end_of_cmd].strip
        vparams = command.from(end_of_cmd).strip
      else
        vc = command.from(7).strip
        vparams = ""
      end

      unless vc.empty?
        if vch = VoicedCommandHandler[vc]
          return vch.use_voiced_command(vc, pc, vparams)
        end
      end
    end

    false
  end

  def commands : Enumerable(String)
    {"voice"}
  end
end
