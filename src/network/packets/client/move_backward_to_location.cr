class Packets::Incoming::MoveBackwardToLocation < GameClientPacket
  @to_x = 0
  @to_y = 0
  @to_z = 0
  @from_x = 0
  @from_y = 0
  @from_z = 0

  private def read_impl
    @to_x, @to_y, @to_z = d, d, d
    @from_x, @from_y, @from_z = d, d, d

    unless buffer.remaining >= 4
      if Config.l2walker_protection
        warn { "Player #{client.active_char} is trying to use L2Walker." }
        if pc = client.active_char
          Util.punish(pc, "tried to use L2Walker and got kicked.")
        end
      end
    end
  end

  private def run_impl
    return unless pc = active_char

    if Config.player_movement_block_time > 0 && !pc.gm?
      if pc.not_move_until > Time.ms
        send_packet(SystemMessageId::CANNOT_MOVE_WHILE_SPEAKING_TO_AN_NPC)
        action_failed
        return
      end
    end

    if @to_x == @from_x && @to_y == @from_y && @to_z == @from_z
      send_packet(StopMove.new(pc))
      return
    end

    @to_z += pc.template.collision_height

    if pc.tele_mode > 0
      pc.tele_mode = 0 if pc.tele_mode == 1
      action_failed
      pc.tele_to_location(Location.new(@to_x, @to_y, @to_z))
      return
    end

    if pc.out_of_control?
      action_failed
      return
    end

    dx = @to_x.to_f - pc.x
    dy = @to_y.to_f - pc.y

    if Math.pow(dx, 2) + Math.pow(dy, 2) > 98_010_000
      action_failed
      return
    end

    pc.set_intention(AI::MOVE_TO, Location.new(@to_x, @to_y, @to_z))
  end
end
