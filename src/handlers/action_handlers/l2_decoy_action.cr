module ActionHandler::L2DecoyAction
  extend self
  extend ActionHandler

  def action(pc : L2PcInstance, target : L2Object, interact : Bool) : Bool
    if pc.locked_target? && pc.locked_target != target
      pc.send_packet(SystemMessageId::FAILED_CHANGE_TARGET)
      return false
    end

    pc.target = target

    true
  end

  def instance_type : InstanceType
    InstanceType::L2Decoy
  end
end
