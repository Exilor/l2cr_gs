module ActionShiftHandler::L2PcInstanceAction
  extend self
  extend ActionShiftHandler

  def action(pc, target, interact)
    if pc.gm?
      if pc.target != target
        pc.target = target
      end

      if ach = AdminCommandHandler["admin_character_info"]
        ach.use_admin_command("admin_character_info #{target.name}", pc)
      end
    end

    true
  end

  def instance_type
    InstanceType::L2PcInstance
  end
end
