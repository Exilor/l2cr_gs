module ActionHandler::L2ItemInstanceAction
  extend self
  extend ActionHandler

  def action(pc : L2PcInstance, target : L2Object, interact : Bool) : Bool
    castle_id = MercTicketManager.get_ticket_castle_id(target.id)

    if castle_id > 0
      if pc.in_party?
        pc.send_message("You cannot pickup mercenaries while in a party.")
      else
        pc.send_message("Only the castle lord can pickup mercenaries.")
      end

      pc.target = target
      pc.intention = AI::IDLE
    elsif !pc.flying?
      pc.set_intention(AI::PICK_UP, target)
    end

    true
  end

  def instance_type
    InstanceType::L2ItemInstance
  end
end
