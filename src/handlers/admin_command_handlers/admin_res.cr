module AdminCommandHandler::AdminRes
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    if command.starts_with?("admin_res ")
      handle_res(pc, command.split[1])
    elsif command == "admin_res"
      handle_res(pc)
    elsif command.starts_with?("admin_res_monster ")
      handle_non_player_res(pc, command.split[1])
    elsif command == "admin_res_monster"
      handle_non_player_res(pc)
    end

    true
  end

  private def handle_res(pc, param = nil)
    obj = pc.target.as?(L2Character)

    if param
      if player = L2World.get_player(param)
        obj = player
      else
        begin
          radius = param.to_i
          pc.known_list.get_known_players_in_radius(radius) do |kp|
            do_resurrect(kp)
          end
          pc.send_message("Resurrected all players within a #{radius} unit radius.")
          return
        rescue
          pc.send_message("Enter a valid player name or radius.")
          return
        end
      end
    end

    obj ||= pc

    if obj.is_a?(L2ControllableMobInstance)
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      return
    end

    do_resurrect(obj)

    debug { "GM #{pc} (#{pc.l2id}) resurrected #{obj}." }
  end

  private def handle_non_player_res(pc, radius_str = "")
    obj = pc.target.as?(L2Character)
    begin
      radius = 0
      unless radius_str.empty?
        radius = radius_str.to_i
        pc.known_list.get_known_characters_in_radius(radius) do |kc|
          unless kc.is_a?(L2PcInstance) || kc.is_a?(L2ControllableMobInstance)
            do_resurrect(kc)
          end
        end

        pc.send_message("Resurrected all non-players within a #{radius} unit radius.")
      end
    rescue
      pc.send_message("Enter a valid radius.")
      return
    end

    if obj.is_a?(L2PcInstance) || obj.is_a?(L2ControllableMobInstance)
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      return
    end

    do_resurrect(obj) if obj
  end

  private def do_resurrect(char)
    return unless char.dead?

    if char.is_a?(L2PcInstance)
      char.do_revive(100.0)
    else
      DecayTaskManager.cancel(char)
      char.do_revive
    end
  end

  def commands
    {"admin_res", "admin_res_monster"}
  end
end
