module ActionHandler::L2PcInstanceAction
  extend self
  extend ActionHandler

  private CURSED_WEAPON_VICTIM_MIN_LEVEL = 21

  def action(pc : L2PcInstance, target : L2Object, interact : Bool) : Bool
    # TODO: TvTEvent
    # unless TvTEvent.on_action(pc, target.l2id)
    #   return false
    # end

    return false if pc.out_of_control?

    if pc.locked_target? && pc.locked_target != target
      pc.send_packet(SystemMessageId::FAILED_CHANGE_TARGET)
      return false
    end

    if pc.target != target
      pc.target = target
    elsif interact
      player = target.acting_player.not_nil!
      if !player.private_store_type.none?
        pc.set_intention(AI::INTERACT, player)
      else
        if player.auto_attackable?(pc)
          if (player.cursed_weapon_equipped? && pc.level < CURSED_WEAPON_VICTIM_MIN_LEVEL) || (pc.cursed_weapon_equipped? && player.level < CURSED_WEAPON_VICTIM_MIN_LEVEL)
            pc.action_failed
          else
            if GeoData.can_see_target?(pc, player)
              pc.set_intention(AI::ATTACK, player)
            else
              dst = GeoData.move_check(pc, player)
              pc.set_intention(AI::MOVE_TO, dst)
            end

            pc.on_action_request
          end
        else
          pc.action_failed
          if GeoData.can_see_target?(pc, player)
            pc.set_intention(AI::FOLLOW, player)
          else
            dst = GeoData.move_check(pc, player)
            pc.set_intention(AI::MOVE_TO, dst)
          end
        end
      end
    end

    true
  end

  def instance_type : InstanceType
    InstanceType::L2PcInstance
  end
end
