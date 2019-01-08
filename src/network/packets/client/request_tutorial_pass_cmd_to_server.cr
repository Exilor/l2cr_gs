class Packets::Incoming::RequestTutorialPassCmdToServer < GameClientPacket
  @bypass = ""

  def read_impl
    @bypass = s
  end

  def run_impl
    return unless pc = active_char
    debug @bypass

    OnPlayerTutorialCmd.new(pc, @bypass).async(pc)
  end
end
