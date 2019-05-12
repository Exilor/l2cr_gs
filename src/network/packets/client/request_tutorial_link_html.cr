class Packets::Incoming::RequestTutorialLinkHtml < GameClientPacket
  @bypass = ""

  private def read_impl
    @bypass = s
  end

  private def run_impl
    if pc = active_char
      OnPlayerTutorialEvent.new(pc, @bypass).async(pc)
    end
  end
end
