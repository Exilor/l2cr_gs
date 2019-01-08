class Packets::Outgoing::ExValidateLocationInAirship < GameServerPacket
  @pc_id : Int32
  @ship_id : Int32
  @pos : Location
  @heading : Int32

  def initialize(pc : L2PcInstance)
    @pc_id = pc.l2id
    @ship_id = pc.airship!.l2id
    @pos = pc.in_vehicle_position.not_nil!
    @heading = pc.heading
  end

  def write_impl
    c 0xfe
    h 0x6f

    d @pc_id
    d @ship_id
    l @pos
    d @heading
  end
end
