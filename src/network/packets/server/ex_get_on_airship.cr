class Packets::Outgoing::ExGetOnAirship < GameServerPacket
  @pc_id : Int32
  @ship_id : Int32
  @pos : Location

  def initialize(pc : L2PcInstance, ship : L2Character)
    @pc_id = pc.l2id
    @ship_id = ship.l2id
    @pos = pc.in_vehicle_position.not_nil!
  end

  def write_impl
    c 0xfe
    h 0x63

    d @pc_id
    d @ship_id
    l @pos
  end
end
