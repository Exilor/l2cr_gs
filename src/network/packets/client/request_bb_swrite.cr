class Packets::Incoming::RequestBBSwrite < GameClientPacket
  @url = ""
  @arg1 = ""
  @arg2 = ""
  @arg3 = ""
  @arg4 = ""
  @arg5 = ""

  def read_impl
    @url = s
    @arg1 = s
    @arg2 = s
    @arg3 = s
    @arg4 = s
    @arg5 = s
  end

  def run_impl
    return unless pc = active_char
    CommunityBoardHandler.handle_write_command(pc, @url, @arg1, @arg2, @arg3, @arg4, @arg5)
  end
end
