class Packets::Incoming::RequestGetOffVehicle < GameClientPacket
  @boat_id = 0
  @x = 0
  @y = 0
  @z = 0

  private def read_impl
    @boat_id = d
    @x = d
    @y = d
    @z = d
  end

  private def run_impl
    return unless pc = active_char

    if !pc.in_boat? || pc.boat!.l2id != @boat_id || pc.boat!.moving? || !pc.inside_radius?(@x, @y, @z, 1000, true, false)
      debug { pc.name + " can't get off vehicle." }
      action_failed
      return
    end

    pc.broadcast_packet(StopMoveInVehicle.new(pc, @boat_id))
    pc.vehicle = nil
    pc.in_vehicle_position = nil
    action_failed
    pc.broadcast_packet(GetOffVehicle.new(pc.l2id, @boat_id, @x, @y, @z))
    pc.set_xyz(@x, @y, @z)
    pc.inside_peace_zone = false
    pc.revalidate_zone(true)
  end
end
