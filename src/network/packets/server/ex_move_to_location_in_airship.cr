class Packets::Outgoing::ExMoveToLocationInAirship < GameServerPacket
  @pc_id : Int32
  @ship_id : Int32
  @destination : Location
  @heading : Int32

  def initialize(pc : L2PcInstance)
    @pc_id = pc.l2id
    @ship_id = pc.airship!.l2id
    @destination = pc.in_vehicle_position.not_nil!
    @heading = pc.heading
  end

  def write_impl
    c 0xfe
    h 0x6d

    d @pc_id
    d @ship_id
    l @destination
    d @heading
  end
end
