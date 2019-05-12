class Packets::Incoming::MoveToLocationInAirship < GameClientPacket
  @ship_id = 0
  @target_x = 0
  @target_y = 0
  @target_z = 0
  @origin_x = 0
  @origin_y = 0
  @origin_z = 0

  private def read_impl
    @ship_id = d
    @target_x = d
    @target_y = d
    @target_z = d
    @origin_x = d
    @origin_y = d
    @origin_z = d
  end

  private def run_impl
    return unless pc = active_char

    if @target_x == @origin_x && @target_y == @origin_y
      if @target_z == @origin_z
        send_packet(StopMoveInVehicle.new(pc, @ship_id))
        return
      end
    end

    if pc.attacking_now? && pc.active_weapon_item?.try &.bow?
      action_failed
      return
    end

    if pc.sitting? || pc.movement_disabled?
      action_failed
      return
    end

    unless airship = pc.airship
      action_failed
      return
    end

    if airship.l2id != @ship_id
      action_failed
      return
    end

    pc.in_vehicle_position = Location.new(@target_x, @target_y, @target_z)
    pc.broadcast_packet(ExMoveToLocationInAirship.new(pc))
  end
end
