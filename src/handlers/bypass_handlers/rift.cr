module BypassHandler::Rift
  extend self
  extend BypassHandler

  def use_bypass(command, pc, target)
    unless target.is_a?(L2Npc)
      return false
    end

    command = command.downcase

    if command.starts_with?(commands[0]) # enter rift
      begin
        b1 = command.from(10).to_i8 # selected area (recruit, solder...)
        DimensionalRiftManager.start(pc, b1, target)
        return true
      rescue e
        error e
      end
    else
      if command.starts_with?(commands[1]) # change room
        if rift = pc.party.try &.dimensional_rift
          rift.manual_teleport(pc, target)
        else
          DimensionalRiftManager.handle_cheat(pc, target)
        end
      elsif command.starts_with?(commands[2]) # exit rift
        if rift = pc.party.try &.dimensional_rift
          rift.manual_exit_rift(pc, target)
        else
          DimensionalRiftManager.handle_cheat(pc, target)
        end
      end

      return true
    end

    false
  end

  def commands
    {"enterrift", "changeriftroom", "exitrift"}
  end
end
