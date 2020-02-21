module BypassHandler::EventEngine
  extend self
  extend BypassHandler

  def use_bypass(command, pc, target)
    return false unless target.is_a?(L2Npc)

    begin
      if command.casecmp?("event_participate")
        L2Event.register_player(pc)
        return true
      elsif command.casecmp?("event_unregister")
        L2Event.remove_and_reset_player(pc)
        return true
      end
    rescue e
      error e
    end

    false
  end

  def commands
    {"event_participate", "event_unregister"}
  end
end
