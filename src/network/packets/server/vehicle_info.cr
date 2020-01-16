class Packets::Outgoing::VehicleInfo < GameServerPacket
  @l2id : Int32
  @x : Int32
  @y : Int32
  @z : Int32
  @heading : Int32

  def initialize(boat : L2BoatInstance)
    @l2id = boat.l2id
    @x, @y, @z = boat.xyz
    @heading = boat.heading
  end

  private def write_impl
    c 0x60

    d @l2id
    d @x
    d @y
    d @z
    d @heading
  end
end
