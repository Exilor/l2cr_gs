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
    pc.stop_move(nil)
    pc.broadcast_packet(ValidateLocation.new(pc))
    msu = MagicSkillUse.new(pc, pc, 628, 1, 1, 1)
    pc.broadcast_packet(msu)


    if smn = pc.summon
      msu = MagicSkillUse.new(smn, smn, 628, 1, 1, 1)
      smn.broadcast_packet(msu)
      smn.tele_to_location(*pc.xyz)
      smn.follow_owner
    end
  end

  def commands
    {"admin_warp"}
  end
end
