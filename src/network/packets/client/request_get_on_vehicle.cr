class Packets::Incoming::RequestGetOnVehicle < GameClientPacket
  @boat_id = 0
  @pos = uninitialized Location

  private def read_impl
    @boat_id = d
    @pos = Location.new(d, d, d)
  end

  private def run_impl
    return unless pc = active_char

    if pc.in_boat?
      boat = pc.boat!
      if boat.l2id != @boat_id
        action_failed
        return
      end
    else
      boat = BoatManager[@boat_id]?
      unless boat
        action_failed
        return
      end

      if boat.moving?
        action_failed
        return
      end

      unless pc.inside_radius?(boat, 1000, true, false)
        action_failed
        return
      end
    end

    pc.in_vehicle_position = @pos
    pc.vehicle = boat
    pc.broadcast_packet(GetOnVehicle.new(pc.l2id, boat.l2id, @pos))
    pc.set_xyz(*boat.xyz)
    pc.inside_peace_zone = true
    pc.revalidate_zone(true)
  end
end
