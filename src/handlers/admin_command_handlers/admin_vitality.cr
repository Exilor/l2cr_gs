module AdminCommandHandler::AdminVitality
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    unless Config.enable_vitality
      pc.send_message("Vitality is not enabled")
      return false
    end

    level = 0
    vitality = 0

    st = command.split
    cmd = st.shift

    if target = pc.target.as?(L2PcInstance)
      if cmd == "admin_set_vitality"
        begin
          vitality = st.shift.to_i
        rescue
          pc.send_message("Incorrect vitality")
        end

        target.set_vitality_points(vitality, true)
        target.send_message("Admin set your Vitality points to #{vitality}")
      elsif cmd == "admin_set_vitality_level"
        begin
          level = st.shift.to_i
        rescue
          pc.send_message("Incorrect vitality level (0-4)")
        end

        if level.between?(0, 4)
          if level == 0
            vitality = PcStat::MIN_VITALITY_POINTS
          else
            vitality = PcStat::VITALITY_LEVELS[level &- 1]
          end
          target.set_vitality_points(vitality, true)
          target.send_message("Admin set your Vitality level to #{level}")
        else
          pc.send_message("Incorrect vitality level (0-4)")
        end
      elsif cmd == "admin_full_vitality"
        target.set_vitality_points(PcStat::MAX_VITALITY_POINTS, true)
        target.send_message("Admin completly recharged your Vitality")
      elsif cmd == "admin_empty_vitality"
        target.set_vitality_points(PcStat::MIN_VITALITY_POINTS, true)
        target.send_message("Admin completly emptied your Vitality")
      elsif cmd == "admin_get_vitality"
        level = target.vitality_level
        vitality = target.vitality_points

        pc.send_message("Player vitality level: #{level}")
        pc.send_message("Player vitality points: #{vitality}")
      end

      return true
    end

    pc.send_message("Target not found or not a player")

    false
  end

  def commands
    {
      "admin_set_vitality",
      "admin_set_vitality_level",
      "admin_full_vitality",
      "admin_empty_vitality",
      "admin_get_vitality"
    }
  end
end
