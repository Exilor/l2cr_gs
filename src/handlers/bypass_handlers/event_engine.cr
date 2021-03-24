module BypassHandler::EventEngine
  extend self
  extend BypassHandler

  def use_bypass(command : String, pc : L2PcInstance, target : L2Character?) : Bool
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

  def commands : Enumerable(String)
    {"event_participate", "event_unregister"}
  end
end
