module AdminCommandHandler::AdminCamera
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    unless target = pc.target.as?(L2Character)
      pc.send_packet(SystemMessageId::TARGET_CANT_FOUND)
      return false
    end

    com = command.split
    case com[0]
    when "admin_cam"
      if com.size != 12
        pc.send_message("Usage: #cam force angle1 angle2 time range duration relYaw relPitch isWide relAngle")
        return false
      end
      AbstractScript.special_camera(pc, target, com[1].to_i, com[2].to_i, com[3].to_i, com[4].to_i, com[5].to_i, com[6].to_i, com[7].to_i, com[8].to_i, com[9].to_i, com[10].to_i)
    when "admin_camex"
      if com.size != 10
        pc.send_message("Usage: #camex force angle1 angle2 time duration relYaw relPitch isWide relAngle")
        return false
      end
      AbstractScript.special_camera_ex(pc, target, com[1].to_i, com[2].to_i, com[3].to_i, com[4].to_i, com[5].to_i, com[6].to_i, com[7].to_i, com[8].to_i, com[9].to_i)
    when "admin_cam3"
      if com.size != 12
        pc.send_message("Usage: #cam3 force angle1 angle2 time range duration relYaw relPitch isWide relAngle unk")
        return false
      end
      AbstractScript.special_camera_3(pc, target, com[1].to_i, com[2].to_i, com[3].to_i, com[4].to_i, com[5].to_i, com[6].to_i, com[7].to_i, com[8].to_i, com[9].to_i, com[10].to_i, com[11].to_i)
    else
      # automatically added
    end


    true
  end

  def commands
    {
      "admin_cam",
      "admin_camex",
      "admin_cam3"
    }
  end
end