class Packets::Incoming::RequestTutorialQuestionMark < GameClientPacket
  @number = 0

  private def read_impl
    @number = d
  end

  private def run_impl
    if pc = active_char
      OnPlayerTutorialQuestionMark.new(pc, @number).async(pc)
    end
  end
end
