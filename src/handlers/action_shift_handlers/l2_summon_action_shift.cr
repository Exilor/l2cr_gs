module ActionShiftHandler::L2SummonAction
  extend self
  extend ActionShiftHandler

  def action(pc, target, interact)
    if pc.access_level.gm?
      if pc.target != target
        pc.target = target
      end

      if ach = AdminCommandHandler["admin_summon_info"]
        ach.use_admin_command("admin_summon_info", pc)
      end
    end

    true
  end

  def instance_type
    InstanceType::L2Summon
  end
end
