class Packets::Incoming::ExGetOnAirship < GameClientPacket
  @x = 0
  @y = 0
  @z = 0
  @ship_id = 0

  private def read_impl
    @x, @y, @z = d, d, d
    @ship_id = d
  end

  private def run_impl
    # debug { "[T1:ExGetOnAirship] x: #{@x}." }
    # debug { "[T1:ExGetOnAirship] y: #{@y}." }
    # debug { "[T1:ExGetOnAirship] z: #{@z}." }
    # debug { "[T1:ExGetOnAirship] ship ID: #{@ship_id}." }
  end
end
