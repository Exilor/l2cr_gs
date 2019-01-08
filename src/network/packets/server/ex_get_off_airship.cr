class Packets::Outgoing::ExGetOffAirship < GameServerPacket
  @pc_id : Int32
  @ship_id : Int32

  def initialize(pc : L2Character, ship : L2Character, @x : Int32, @y : Int32, @z : Int32)
    @pc_id = pc.l2id
    @ship_id = ship.l2id
  end

  def write_impl
    c 0xfe
    h 0x64

    d @pc_id
    d @ship_id
    d @x
    d @y
    d @z
  end
end
