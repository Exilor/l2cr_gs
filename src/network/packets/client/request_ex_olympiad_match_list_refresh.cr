class Packets::Incoming::RequestExOlympiadMatchListRefresh < GameClientPacket
  def read_impl
    # no-op
  end

  def run_impl
    active_char.try &.send_packet(ExOlympiadMatchList.new)
  end
end
