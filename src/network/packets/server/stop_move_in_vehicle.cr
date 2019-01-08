class Packets::Outgoing::StopMoveInVehicle < GameServerPacket
  @pc_id : Int32
  @pos : Location
  @heading : Int32

  def initialize(pc : L2PcInstance, @boat_id : Int32)
    @pc_id = pc.l2id
    @pos = pc.in_vehicle_position
    @heading = pc.heading
  end

  def write_impl
    c 0x7f

    d @pc_id
    d @boat_id
    l @pos
    d @heading
  end
end
