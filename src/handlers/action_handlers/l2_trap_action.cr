module ActionHandler::L2TrapAction
  extend self
  extend ActionHandler

  def action(pc, target, interact) : Bool
    if pc.locked_target? && pc.locked_target != target
      pc.send_packet(SystemMessageId::FAILED_CHANGE_TARGET)
      false
    else
      pc.target = target
      true
    end
  end

  def instance_type : InstanceType
    InstanceType::L2TrapInstance
  end
end
