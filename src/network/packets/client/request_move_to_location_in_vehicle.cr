class Packets::Incoming::RequestMoveToLocationInVehicle < GameClientPacket
  @boat_id = 0

  @target_x = 0
  @target_y = 0
  @target_z = 0

  @origin_x = 0
  @origin_y = 0
  @origin_z = 0

  def read_impl
    @boat_id = d

    @target_x = d
    @target_y = d
    @target_z = d

    @origin_x = d
    @origin_y = d
    @origin_z = d
  end

  def run_impl
    return unless pc = active_char

    # debug "#{pc.name} is at #{[pc.x, pc.y, pc.z]} and wants to move to move from #{[@origin_x, @origin_y, @origin_z]} to #{[@target_x, @target_y, @target_z]}."

    if Config.player_movement_block_time && !pc.gm?
      if pc.not_move_until > Time.ms
        pc.send_packet(SystemMessageId::CANNOT_MOVE_WHILE_SPEAKING_TO_AN_NPC)
        action_failed
        return
      end
    end

    if @target_x == @origin_x && @target_y == @origin_y
      if @target_z == @origin_z
        pc.send_packet(StopMoveInVehicle.new(pc, @boat_id))
        return
      end
    end

    if pc.attacking_now? && pc.active_weapon_item?
      if pc.active_weapon_item.item_type == WeaponType::BOW
        action_failed
        return
      end
    end

    if pc.sitting? || pc.movement_disabled?
      action_failed
      return
    end

    if pc.has_summon?
      pc.send_packet(SystemMessageId::RELEASE_PET_ON_BOAT)
      action_failed
      return
    end

    if pc.transformed?
      pc.send_packet(SystemMessageId::CANT_POLYMORPH_ON_BOAT)
      action_failed
      return
    end

    if pc.in_boat?
      boat = pc.boat!
      if boat.l2id != @boat_id
        action_failed
        return
      end
    else
      boat = BoatManager[@boat_id]?

      if boat.nil? || !boat.inside_radius?(pc, 300, true, false)
        action_failed
        return
      end

      pc.vehicle = boat
    end

    pos = Location.new(@target_x, @target_y, @target_z)
    origin_pos = Location.new(@origin_x, @origin_y, @origin_z)
    pc.in_vehicle_position = pos
    pc.broadcast_packet(MoveToLocationInVehicle.new(pc, pos, origin_pos))
  end
end
