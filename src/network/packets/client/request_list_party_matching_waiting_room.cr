class Packets::Incoming::RequestListPartyMatchingWaitingRoom < GameClientPacket
  @page = 0
  @min_lvl = 0
  @max_lvl = 0
  @mode = 0

  private def read_impl
    @page = d
    @min_lvl = d
    @max_lvl = d
    @mode = d
  end

  private def run_impl
    return unless pc = active_char
    # packet = ExListPartyMatchingWaitingRoom.new(pc, @page, @min_lvl, @max_lvl, @mode)
    # @page is unused
    packet = ExListPartyMatchingWaitingRoom.new(pc, @min_lvl, @max_lvl, @mode)
    pc.send_packet(packet)
  end
end
