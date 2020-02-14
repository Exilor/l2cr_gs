class Packets::Incoming::RequestExCubeGameChangeTeam < GameClientPacket
  @arena = 0
  @team = 0

  private def read_impl
    @arena = d + 1
    @team = d
  end

  private def run_impl
    return unless pc = active_char

    if HandysBlockCheckerManager.arena_being_used?(@arena)
      return
    end

    case @team
    when 0, 1
      HandysBlockCheckerManager.change_player_to_team(pc, @arena, @team)
    when -1
      team = HandysBlockCheckerManager.get_holder(@arena).get_player_team(pc)
      if team > -1
        HandysBlockCheckerManager.remove_player(pc, @arena, @team)
      end
    else
      warn { "Wrong cube game team id #{@team}." }
    end
  end
end
