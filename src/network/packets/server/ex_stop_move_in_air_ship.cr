class Packets::Outgoing::ExStopMoveInAirShip < GameServerPacket
  @pc_id : Int32
  @loc : Location
  @heading : Int32

  def initialize(pc : L2PcInstance, @ship_id : Int32)
    @pc_id = pc.l2id
    @loc = pc.in_vehicle_position.not_nil!
    @heading = pc.heading
  end

  private def write_impl
    c 0xfe
    h 0x6e

    d @pc_id
    d @ship_id
    l @loc
    d @heading
  end
end
