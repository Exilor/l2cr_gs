class Packets::Outgoing::MoveToLocationInVehicle < GameServerPacket
  @pc_id : Int32
  @boat_id : Int32

  def initialize(pc : L2PcInstance, @destination : Location, @origin : Location)
    @pc_id = pc.l2id
    @boat_id = pc.boat!.l2id
  end

  def write_impl
    c 0x7e

    d @pc_id
    d @boat_id
    l @destination
    l @origin
  end
end
