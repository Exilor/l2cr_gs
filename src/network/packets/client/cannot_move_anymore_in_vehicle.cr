class Packets::Incoming::CannotMoveAnymoreInVehicle < GameClientPacket
  @boat_id = 0
  @x = 0
  @y = 0
  @z = 0
  @heading = 0

  def read_impl
    @boat_id = d
    @x, @y, @z = d, d, d
    @heading = d
  end

  def run_impl
    return unless pc = active_char
    return unless boat = pc.boat
    return unless boat.l2id == @boat_id

    pc.in_vehicle_position = Location.new(@x, @y, @z)
    pc.heading = @heading
    pc.broadcast_packet(StopMoveInVehicle.new(pc, @boat_id))
  end
end
