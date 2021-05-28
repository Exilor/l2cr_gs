module AdminCommandHandler::AdminLevel
  extend self
  extend AdminCommandHandler

  def use_admin_command(command : String, pc : L2PcInstance) : Bool
    target = pc.target
    st = command.split
    actual_command = st.shift

    val = ""
    if st.size >= 1
      val = st.shift
    end

    if actual_command.casecmp?("admin_add_level")
      begin
        if target.is_a?(L2PcInstance)
          target.add_level(val.to_i)
        end
      rescue e
        pc.send_message("Wrong number format")
      end
    elsif actual_command.casecmp?("admin_set_level")
      begin
        unless target.is_a?(L2PcInstance)
          pc.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
          return false
        end
        old_level = target.level
        new_level = val.to_i

        if new_level < 1
          new_level = 1
        end
        target.level = new_level
        target.exp = ExperienceData.get_exp_for_level(Math.min(new_level, target.max_exp_level))
        target.on_level_change(new_level > old_level)
        target.broadcast_info
      rescue e
        pc.send_message("Level require number as value")
        return false
      end
    end

    true
  end

  def commands : Enumerable(String)
    {
      "admin_add_level",
      "admin_set_level"
    }
  end
end
