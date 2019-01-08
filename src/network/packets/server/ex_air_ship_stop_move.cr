class Packets::Outgoing::ExAirShipStopMove < GameServerPacket
  @player_id : Int32
  @airship_id : Int32

  def initialize(pc : L2PcInstance, ship : L2AirshipInstance, @x : Int32, @y : Int32, @z : Int32)
    @player_id = pc.l2id
    @airship_id = ship.l2id
  end

  def write_impl
    c 0xfe
    h 0x66

    d @airship_id
    d @player_id
    d @x
    d @y
    d @z
  end
end
