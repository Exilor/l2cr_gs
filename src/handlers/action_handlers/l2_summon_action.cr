module ActionHandler::L2SummonAction
  extend self
  extend ActionHandler

  def action(pc : L2PcInstance, target : L2Object, interact : Bool) : Bool
    locked_target = pc.locked_target?
    if locked_target && locked_target != target
      pc.send_packet(SystemMessageId::FAILED_CHANGE_TARGET)
      return false
    end

    target = target.as(L2Summon)

    if pc == target.owner && pc.target == target
      pc.send_packet(PetStatusShow.new(target))
      pc.update_not_move_until
      pc.action_failed

      OnPlayerSummonTalk.new(target).async(target)
    elsif pc.target != target
      pc.target = target
    elsif interact
      if target.auto_attackable?(pc)
        if GeoData.can_see_target?(pc, target)
          pc.set_intention(AI::ATTACK, target)
          pc.on_action_request
        end
      else
        pc.action_failed
        if target.inside_radius?(pc, 150, false, false)
          pc.update_not_move_until
        else
          if GeoData.can_see_target?(pc, target)
            pc.set_intention(AI::FOLLOW, target)
          end
        end
      end
    end

    true
  end

  def instance_type
    InstanceType::L2Summon
  end
end
