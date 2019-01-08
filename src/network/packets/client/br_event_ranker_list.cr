class Packets::Incoming::BrEventRankerList < GameClientPacket
  @event_id = 0
  @day = 0
  @ranking = 0

  def read_impl
    @event_id = d
    @day = d
    @ranking = d
  end

  def run_impl
    send_packet(ExBrLoadEventTopRankers.new(@event_id, @day, 0, 0, 0))
  end
end
