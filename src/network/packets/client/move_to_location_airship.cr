class Packets::Incoming::MoveToLocationAirship < GameClientPacket
  private MIN_Z = -895
  private MAX_Z = 6105
  private STEP  = 300

  @command = 0
  @param1 = 0
  @param2 = 0

  private def read_impl
    @command = d
    @param1 = d
    @param2 = buffer.remaining > 3 ? d : 0
  end

  private def run_impl
    # warn "Commented out."
    return unless pc = active_char
    return unless ship = pc.airship
    return unless ship.captain?(pc)

    z = ship.z

    return if @command.between?(0, 3) && !ship.can_be_controlled?

    case @command
    when 0
      if @param1 < L2World::GRACIA_MAX_X
        ship.set_intention(AI::MOVE_TO, Location.new(@param1, @param2, z))
      end
    when 1
      ship.intention = AI::ACTIVE
    when 2
      if z < L2World::GRACIA_MAX_Z
        z = Math.min(z + STEP, L2World::GRACIA_MAX_Z)
        ship.set_intention(AI::MOVE_TO, Location.new(ship.x, ship.y, z))
      end
    when 3
      if z > L2World::GRACIA_MIN_Z
        z = Math.max(z - STEP, L2World::GRACIA_MIN_Z)
        ship.set_intention(AI::MOVE_TO, Location.new(ship.x, ship.y, z))
      end
    when 4
      return if !ship.in_dock? || ship.moving?

      dst = AirshipManager.get_teleport_destination(ship.dock_id, @param1)
      return unless dst

      fuel_consumption = AirshipManager.get_fuel_consumption(ship.dock_id, @param1)
      if fuel_consumption > 0
        if fuel_consumption > ship.fuel
          send_packet(SystemMessageId::THE_AIRSHIP_CANNOT_TELEPORT)
          return
        end

        ship.fuel -= fuel_consumption
      end

      ship.execute_path(dst)
    end

  end
end
