class Packets::Incoming::RequestListPartyMatchingWaitingRoom < GameClientPacket
  @classes = Set(Int32).new
  @page = 0
  @min_lvl = 0
  @max_lvl = 0
  @filter = ""

  private def read_impl
    @page = d
    @min_lvl = d
    @max_lvl = d
    size = d
    size.times do
      @classes << d
    end
    if remaining?
      @filter = s
    end
  end

  private def run_impl
    return unless pc = active_char
    p = ExListPartyMatchingWaitingRoom.new(@page, @min_lvl, @max_lvl, @classes, @filter)
    pc.send_packet(p)
  end
end
