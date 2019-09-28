module AdminCommandHandler::AdminWarp
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    if command == "admin_warp"
      warp(pc)
    end

    true
  end

  private def warp(pc)
    unless pc.moving?
      pc.send_message("You need to be moving in order to warp.")
      return
    end

    pc.set_xyz(pc.x_destination, pc.y_destination, pc.z_destination)
    pc.stop_move
    pc.broadcast_packet(ValidateLocation.new(pc))
    msu = MagicSkillUse.new(pc, pc, 628, 1, 1, 1)
    pc.broadcast_packet(msu)


    if summon = pc.summon
      msu = MagicSkillUse.new(summon, summon, 628, 1, 1, 1)
      summon.broadcast_packet(msu)
      summon.tele_to_location(*pc.xyz)
      summon.follow_owner
    end
  end

  def commands
    {"admin_warp"}
  end
end
