class Packets::Outgoing::ExStopMoveAirship < GameServerPacket
  @l2id : Int32
  @x : Int32
  @y : Int32
  @z : Int32
  @heading : Int32

  def initialize(ship : L2Character)
    @l2id = ship.l2id
    @x, @y, @z = ship.xyz
    @heading = ship.heading
  end

  private def write_impl
    c 0xfe
    h 0x66

    d @l2id
    d @x
    d @y
    d @z
    d @heading
  end
end
