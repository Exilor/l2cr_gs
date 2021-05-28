module ActionHandler::L2ArtefactInstanceAction
  extend self
  extend ActionHandler

  def action(pc : L2PcInstance, target : L2Object, interact : Bool) : Bool
    return false unless target.is_a?(L2Npc)

    unless target.can_target?(pc)
      return false
    end

    if pc.target != target
      pc.target = target
    elsif interact
      unless target.can_interact?(pc)
        pc.set_intention(AI::INTERACT, target)
      end
    end

    true
  end

  def instance_type : InstanceType
    InstanceType::L2ArtefactInstance
  end
end
