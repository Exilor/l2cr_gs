module AdminCommandHandler::AdminDoorControl
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    begin
      if command.starts_with?("admin_open ")
        door_id = command.from(11).to_i
        if door = DoorData.get_door(door_id)
          door.open_me
        else
          CastleManager.castles.each do |castle|
            if door = castle.get_door(door_id)
              door.open_me
            end
          end
        end
      elsif command.starts_with?("admin_close ")
        door_id = command.from(12).to_i
        if door = DoorData.get_door(door_id)
          door.close_me
        else
          CastleManager.castles.each do |castle|
            if door = castle.get_door(door_id)
              door.close_me
            end
          end
        end
      end

      if command == "admin_closeall"
        DoorData.doors.each &.close_me
        CastleManager.castles.each &.doors.each &.close_me
      end

      if command == "admin_openall"
        DoorData.doors.each &.open_me
        CastleManager.castles.each &.doors.each &.open_me
      end

      if command == "admin_open"
        target = pc.target
        if target.is_a?(L2DoorInstance)
          target.open_me
        else
          pc.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
        end
      end

      if command == "admin_close"
        target = pc.target
        if target.is_a?(L2DoorInstance)
          target.close_me
        else
          pc.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
        end
      end
    rescue e
      error e
    end

    true
  end

  def commands
    {
      "admin_open",
      "admin_close",
      "admin_openall",
      "admin_closeall"
    }
  end
end
