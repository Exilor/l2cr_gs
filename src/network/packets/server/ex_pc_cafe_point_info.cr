class Packets::Outgoing::ExPCCafePointInfo < GameServerPacket
  def initialize
    @points = 0
    @m_add_points = 0
    @remain_time = 0
    @m_period_type = 0
    @point_type = 0
    @time = 0
  end

  def initialize(points : Int32, m_add_points : Int32, time : Int32)
    @points = points
    @m_add_points = m_add_points
    @time = time
    @m_period_type = 1
    @remain_time = 42
    @point_type = m_add_points < 0 ? 3 : 0
  end

  private def write_impl
    c 0xfe
    h 0x32

    d @points
    d @m_add_points
    c @m_period_type
    d @remain_time
    c @point_type
    d @time &* 3
  end
end
