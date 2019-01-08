module ActionHandler::L2DoorInstanceAction
  extend self
  extend ActionHandler

  def action(pc, door, interact) : Bool
    return false unless door.is_a?(L2DoorInstance)

    if pc.target != door
      pc.target = door
    elsif interact
      if door.auto_attackable?(pc)
        if (pc.z - door.z).abs < 400
          pc.set_intention(AI::ATTACK, door)
        end
      elsif pc.clan? && door.clan_hall? && pc.clan_id == door.clan_hall.owner_id
        if !door.inside_radius?(pc, L2Npc::INTERACTION_DISTANCE, false, false)
          pc.set_intention(AI::INTERACT, door)
        elsif !door.clan_hall.siegable_hall? || !door.clan_hall.as(SiegableHall).in_siege?
          pc.add_script(DoorRequestHolder.new(door))
          if !door.open?
            pc.send_packet(ConfirmDlg.new(1140))
          else
            pc.send_packet(ConfirmDlg.new(1141))
          end
        end
      elsif pc.clan? && door.fort? && pc.clan == door.fort.owner_clan?
        if door.openable_by_skill? && !door.fort.siege.in_progress?
          if !door.inside_radius?(pc, L2Npc::INTERACTION_DISTANCE, false, false)
            pc.set_intention(AI::INTERACT, door)
          else
            pc.add_script(DoorRequestHolder.new(door))
            if !door.open?
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

  def instance_type
    InstanceType::L2DoorInstance
  end
end
