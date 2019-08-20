module AdminCommandHandler::AdminDebug
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    st = command.split

    if st[0].casecmp?(commands[0])
      if st.size > 1
        unless target = L2World.get_player(st[0].strip)
          pc.send_packet(SystemMessageId::TARGET_IS_NOT_FOUND_IN_THE_GAME)
          return true
        end
      else
        target = pc.target
      end

      if target.is_a?(L2Character)
        set_debug(pc, target)
      else
        set_debug(pc, pc)
      end
    end

    true
  end

  private def set_debug(pc, target)
    if target.debugger?
      target.debugger = nil
      pc.send_message("Stopped debugging #{target.name}")
    else
      target.debugger = pc
      pc.send_message("Started debugging #{target.name}")
    end
  end

  def commands
    {"admin_debug"}
  end
end
