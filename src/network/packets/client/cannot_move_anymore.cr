class Packets::Incoming::CannotMoveAnymore < GameClientPacket
  @x = 0
  @y = 0
  @z = 0
  @heading = 0

  private def read_impl
    @x, @y, @z = d, d, d
    @heading = d
  end

  private def run_impl
    return unless pc = active_char

    debug { "client x: #{@x}, client y: #{@y}, client z: #{@z}." }
    debug { "server x: #{pc.x}, server y: #{pc.y}, server z: #{pc.z}." }

    pc.notify_event(AI::ARRIVED_BLOCKED, Location.new(@x, @y, @z, @heading))
  end
end
