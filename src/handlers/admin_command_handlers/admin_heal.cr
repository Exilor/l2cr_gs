module AdminCommandHandler::AdminHeal
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    if command == "admin_heal"
      handle_heal(pc)
    elsif command.starts_with?("admin_heal")
      handle_heal(pc, command.from(11))
    end

    true
  end

  private def handle_heal(pc, target = nil)
    obj = pc.target
    if target
      if player = L2World.get_player(target)
        obj = player
      else
        radius = target.to_i
        pc.known_list.get_known_characters_in_radius(radius) do |char|
          char.heal!
        end
        pc.send_message("Healed characters within #{radius} unit radius.")
        return
      end
    end

    obj ||= pc

    if obj.is_a?(L2Character)
      obj.heal!
    else
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
    end
  end

  def commands
    {"admin_heal"}
  end
end
