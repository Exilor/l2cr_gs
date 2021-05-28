module ActionShiftHandler::L2PcInstanceActionShift
  extend self
  extend ActionShiftHandler

  def action(pc : L2PcInstance, target : L2Object, interact : Bool) : Bool
    if pc.gm?
      if pc.target != target
        pc.target = target
      end

      if ach = AdminCommandHandler["admin_character_info"]
        ach.use_admin_command("admin_character_info " + target.name, pc)
      end
    end

    true
  end

  def instance_type : InstanceType
    InstanceType::L2PcInstance
  end
end
