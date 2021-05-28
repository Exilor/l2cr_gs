module ActionHandler::L2DoorInstanceAction
  extend self
  extend ActionHandler

  def action(pc : L2PcInstance, target : L2Object, interact : Bool) : Bool
    return false unless target.is_a?(L2DoorInstance)

    if pc.target != target
      pc.target = target
    elsif interact
      if target.auto_attackable?(pc)
        if (pc.z - target.z).abs < 400
          pc.set_intention(AI::ATTACK, target)
        end
      elsif pc.clan && target.clan_hall? && pc.clan_id == target.clan_hall.owner_id
        if !target.inside_radius?(pc, L2Npc::INTERACTION_DISTANCE, false, false)
          pc.set_intention(AI::INTERACT, target)
        elsif !target.clan_hall.siegable_hall? || !target.clan_hall.as(SiegableHall).in_siege?
          pc.add_script(DoorRequestHolder.new(target))
          if !target.open?
            pc.send_packet(ConfirmDlg.new(1140))
          else
            pc.send_packet(ConfirmDlg.new(1141))
          end
        end
      elsif pc.clan && target.fort? && pc.clan == target.fort.owner_clan?
        if target.openable_by_skill? && !target.fort.siege.in_progress?
          if !target.inside_radius?(pc, L2Npc::INTERACTION_DISTANCE, false, false)
            pc.set_intention(AI::INTERACT, target)
          else
            pc.add_script(DoorRequestHolder.new(target))
            if !target.open?
              pc.send_packet(ConfirmDlg.new(1140))
            else
              pc.send_packet(ConfirmDlg.new(1141))
            end
          end
        end
      end
    end

    true
  end

  def instance_type : InstanceType
    InstanceType::L2DoorInstance
  end
end
