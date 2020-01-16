class Packets::Outgoing::VehicleStarted < GameServerPacket
  @l2id : Int32

  def initialize(boat : L2Character, @state : Int32)
    @l2id = boat.l2id
  end

  private def write_impl
    c 0xc0

    d @l2id
    d @state
  end
end
