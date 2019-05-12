class Packets::Incoming::RequestExOlympiadMatchListRefresh < GameClientPacket
  private def read_impl
    # no-op
  end

  private def run_impl
    active_char.try &.send_packet(ExOlympiadMatchList.new)
  end
end
