module BypassHandler::OlympiadObservation
  extend self
  extend BypassHandler

  def use_bypass(command : String, pc : L2PcInstance, target : L2Character?) : Bool
    manager = pc.last_folk_npc

    if command.starts_with?(commands[0])
      unless Olympiad.instance.in_comp_period?
        pc.send_packet(SystemMessageId::THE_OLYMPIAD_GAME_IS_NOT_CURRENTLY_IN_PROGRESS)
        return false
      end

      pc.send_packet(ExOlympiadMatchList.new)
    else
      unless manager.is_a?(L2OlympiadManagerInstance)
        return false
      end

      if !pc.in_observer_mode? && !pc.inside_radius?(manager, 300, false, false)
        return false
      end

      if OlympiadManager.registered_in_comp?(pc)
        pc.send_packet(SystemMessageId::WHILE_YOU_ARE_ON_THE_WAITING_LIST_YOU_ARE_NOT_ALLOWED_TO_WATCH_THE_GAME)
        return false
      end

      unless Olympiad.instance.in_comp_period?
        pc.send_packet(SystemMessageId::THE_OLYMPIAD_GAME_IS_NOT_CURRENTLY_IN_PROGRESS)
        return false
      end

      if pc.on_event?
        pc.send_message("You can not observe games while registered on an event")
        return false
      end

      arena_id = command.from(12).strip.to_i
      if next_arena = OlympiadGameManager.get_olympiad_task(arena_id)
        pc.enter_olympiad_observer_mode(next_arena.zone.spectator_spawns[0], arena_id)
        pc.instance_id = next_arena.zone.instance_id
      end
    end

    true
  rescue e
    error e
    false
  end

  def commands : Enumerable(String)
    {"watchmatch", "arenachange"}
  end
end
