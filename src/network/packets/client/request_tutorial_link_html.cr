class Packets::Incoming::RequestTutorialLinkHtml < GameClientPacket
  @bypass = ""

  def read_impl
    @bypass = s
  end

  def run_impl
    if pc = active_char
      OnPlayerTutorialEvent.new(pc, @bypass).async(pc)
    end
  end
end
