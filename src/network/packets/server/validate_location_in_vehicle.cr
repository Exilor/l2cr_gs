class Packets::Outgoing::ValidateLocationInVehicle < GameServerPacket
  @pc_id : Int32
  @boat_id : Int32
  @heading : Int32
  @pos : Location

  def initialize(pc : L2PcInstance)
    @pc_id = pc.l2id
    @boat_id = pc.boat.not_nil!.l2id
    @heading = pc.heading
    @pos = pc.in_vehicle_position.not_nil!
  end

  private def write_impl
    c 0x80

    d @pc_id
    d @boat_id
    l @pos
    d @heading
  end
end
