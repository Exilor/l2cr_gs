module ActionHandler::L2PetInstanceAction
  extend self
  extend ActionHandler

  def action(pc, target, interact) : Bool
    if pc.locked_target? && pc.locked_target != target
      pc.send_packet(SystemMessageId::FAILED_CHANGE_TARGET)
      return false
    end

    unless target.is_a?(L2PetInstance)
      raise "Expected #{target}:#{target.class} to be a L2PetInstance"
    end

    is_owner = pc.l2id == target.owner.l2id

    if is_owner && pc != target.owner
      target.update_ref_owner(pc)
    end

    if pc.target != target
      pc.target = target
    elsif interact
      if target.auto_attackable?(pc) && !is_owner
        if GeoData.can_see_target?(pc, target)
          pc.set_intention(AI::ATTACK, target)
          pc.on_action_request
        end
      elsif !target.inside_radius?(pc, 150, false, false)
        if GeoData.can_see_target?(pc, target)
          pc.set_intention(AI::INTERACT, target)
          pc.on_action_request
        end
      else
        if is_owner
          pc.send_packet(PetStatusShow.new(target))
          OnPlayerSummonTalk.new(target).async(target)
        end

        pc.update_not_move_until
      end
    end

    true
  end

  def instance_type : InstanceType
    InstanceType::L2PetInstance
  end
end
