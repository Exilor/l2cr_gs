module AdminCommandHandler::AdminTvTEvent
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    if command == "admin_tvt_add"
      target = pc.target

      unless target.is_a?(L2PcInstance)
        pc.send_message("A player must be selected.")
        return true
      end

      add(pc, target)
    elsif command == "admin_tvt_remove"
      target = pc.target

      unless target.is_a?(L2PcInstance)
        pc.send_message("A player must be selected.")
        return true
      end

      remove(pc, target)
    elsif command == "admin_tvt_advance"
      TvTManager.skip_delay
    end

    true
  end

  private def add(pc, target)
    if target.on_event?
      pc.send_message("Player is already participating in the event.")
      return
    end

    unless TvTEvent.add_participant(target)
      pc.send_message("Player could not be added.")
      return
    end

    if TvTEvent.started?
      unless coordinates = TvTEvent.get_participant_team_coordinates(target.l2id)
        raise "Couldn't get TvT coordinates for player #{target.name}"
      end

      TvTEventTeleporter.new(target, coordinates.not_nil!, true, false)
    end
  end

  private def remove(pc, target)
    unless TvTEvent.remove_participant(target.l2id)
      pc.send_message("Player is not participating in the event.")
      return
    end

    coordinates = Config.tvt_event_participation_npc_coordinates
    TvTEventTeleporter.new(target, coordinates, true, true)
  end

  def commands
    {
      "admin_tvt_add",
      "admin_tvt_remove",
      "admin_tvt_advance"
    }
  end
end
