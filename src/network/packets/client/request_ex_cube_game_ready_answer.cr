class Packets::Incoming::RequestExCubeGameReadyAnswer < GameClientPacket
  @arena = 0
  @answer = 0

  private def read_impl
    @arena = d + 1
    @answer = d
  end

  private def run_impl
    return unless active_char

    case @answer
    when 0
      # do nothing (answer: no)
    when 1
      # answer ok or time over
      HandysBlockCheckerManager.increase_arena_votes(@arena)
    else
      warn { "Unknown answer with id #{@answer}." }
    end
  end
end
