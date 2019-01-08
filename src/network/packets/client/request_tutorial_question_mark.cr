class Packets::Incoming::RequestTutorialQuestionMark < GameClientPacket
  @number = 0

  def read_impl
    @number = d
  end

  def run_impl
    if pc = active_char
      OnPlayerTutorialQuestionMark.new(pc, @number).async(pc)
    end
  end
end
