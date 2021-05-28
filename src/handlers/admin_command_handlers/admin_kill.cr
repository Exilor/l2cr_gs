module AdminCommandHandler::AdminKill
  extend self
  extend AdminCommandHandler

  def use_admin_command(command : String, pc : L2PcInstance) : Bool
    if command.starts_with?("admin_kill")
      st = command.split
      st.shift

      if !st.empty?
        first_param = st.shift

        if player = L2World.get_player(first_param)
          unless st.empty?
            radius = st.shift.to_i
            player.known_list.get_known_characters_in_radius(radius) do |known_char|
              if known_char.is_a?(L2ControllableMobInstance) || pc == known_char
                next
              end

              kill(pc, known_char)
            end
            pc.send_message("Killed all characters within a #{radius} unit radius.")
          end

          kill(pc, player)
          return true
        else
          radius = first_param.to_i
          pc.known_list.get_known_characters_in_radius(radius) do |known_char|
            if known_char.is_a?(L2ControllableMobInstance) || pc == known_char
              next
            end

            kill(pc, known_char)
          end
          pc.send_message("Killed all characters within a #{radius} unit radius.")
          return true
        end
      else
        obj = pc.target
        if obj.is_a?(L2ControllableMobInstance) || !obj.is_a?(L2Character)
          pc.send_packet(SystemMessageId::INCORRECT_TARGET)
        else
          kill(pc, obj)
        end
      end
    end

    true
  end

  private def kill(pc, target)
    if target.is_a?(L2PcInstance)
      unless target.gm?
        target.stop_all_effects
      end
      target.reduce_current_hp(target.max_hp.to_f64 * target.max_cp + 1, pc, nil)
    elsif Config.champion_enable && target.champion?
      target.reduce_current_hp(target.max_hp.to_f64 * Config.champion_hp + 1, pc, nil)
    else
      invul = false
      if target.invul?
        invul = true
        target.invul = false
      end

      target.reduce_current_hp(target.max_hp + 1.0, pc, nil)

      if invul
        target.invul = true
      end
    end
  end

  def commands : Enumerable(String)
    {"admin_kill", "admin_kill_monster"}
  end
end
