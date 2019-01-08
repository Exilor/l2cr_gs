class Packets::Outgoing::ExBrLoadEventTopRankers < GameServerPacket
  initializer event_id: Int32, day: Int32, count: Int32, best_score: Int32,
    my_score: Int32

  def write_impl
    c 0xfe
    h 0xbd

    d @event_id
    d @day
    d @count
    d @best_score
    d @my_score
  end
end
