class Packets::Incoming::ValidatePosition < GameClientPacket
  @x = 0
  @y = 0
  @z = 0
  @heading = 0
  @data = 0

  private def read_impl
    @x = d
    @y = d
    @z = d
    @heading = d
    @data = d
  end

  private def run_impl
    return unless pc = active_char
    return if pc.teleporting? || pc.in_observer_mode?

    real_x, real_y, real_z = pc.xyz

    if @x == 0 && @y == 0
      return if real_x != 0
    end

    dx, dy, dz, diff_sq = 0, 0, 0, 0.0

    if pc.in_boat?
      if Config.coord_synchronize == 2
        dx = @x - pc.in_vehicle_position.x
        dy = @y - pc.in_vehicle_position.y

        diff_sq = (dx * dx) + (dy * dy)
        if diff_sq > 250_000
          pos = pc.in_vehicle_position
          send_packet(GetOnVehicle.new(pc.l2id, @data, pos))
        end
      end

      return
    end

    if pc.in_airship?
      return
    end

    if pc.falling?(@z)
      debug "#{pc.name} is falling."
      return
    end

    dx = @x - real_x
    dy = @y - real_y
    dz = @z - real_z
    diff_sq = (dx * dx) + (dy * dy)

    if pc.flying_mounted? && @x > L2World::GRACIA_MAX_X
      pc.untransform
    end

    if pc.flying? || pc.inside_water_zone?
      pc.set_xyz(real_x, real_y, @z)

      if diff_sq > 90_000
        pc.send_packet(ValidateLocation.new(pc))
      end
    elsif diff_sq < 360_000
      if Config.coord_synchronize == -1
        pc.set_xyz(real_x, real_y, @z)
        return
      end

      if Config.coord_synchronize == 1
        if !pc.moving? || !pc.validate_movement_heading(@heading)
          if diff_sq < 2500
            pc.set_xyz(real_x, real_y, @z)
          else
            pc.set_xyz(@x, @y, @z)
          end
        else
          pc.set_xyz(real_x, real_y, @z)
        end

        pc.heading = @heading
        return
      end

      if diff_sq > 250_000 || dz.abs > 200
        # debug "diff_sq > 250_000 || dz.abs > 200"
        if 200 <= dz.abs <= 1500 && (@z - pc.client_z).abs < 800
          # debug "dz.abs.between?(201, 1499) && (@z - pc.client_z).abs < 800"
          # debug "Setting xyz of #{pc} at #{real_x} #{real_y} #{@z}."
          pc.set_xyz(real_x, real_y, @z) # this was wrong, using real_z instead of real_y.
          real_z = @z
        else
          # debug "Synchronizing server/client position of #{pc.name}."
          pc.send_packet(ValidateLocation.new(pc))
        end
      end
    end

    pc.client_x, pc.client_y, pc.client_z = @x, @y, @z
    pc.client_heading = @heading
    pc.set_last_server_position(real_x, real_y, real_z)
  end
end
