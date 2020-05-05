module VoicedCommandHandler::Hellbound
  extend self
  extend VoicedCommandHandler

  private COMMANDS = {"hellbound"}

  def use_voiced_command(cmd : String, pc : L2PcInstance, params : String) : Bool
    if HellboundEngine.instance.locked?
      pc.send_message("Hellbound is currently locked.")
      return true
    end

    max_trust = HellboundEngine.instance.max_trust
    if max_trust > 0
      trust = "#{HellboundEngine.instance.trust}/#{max_trust}"
    else
      trust = HellboundEngine.instance.trust
    end
    level = HellboundEngine.instance.level
    pc.send_message("Hellbound level: #{level}, trust: #{trust}.")

    true
  end

  def commands : Indexable(String)
    COMMANDS
  end
end
