module AdminCommandHandler::AdminTest
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    if command == "admin_stats"
      pc.send_message("\"admin_stats\" not available.")
    elsif command.starts_with?("admin_skill_test")
      begin
        st = command.split
        st.shift
        id = st.shift.to_i
        if command.starts_with?("admin_skill_test")
          admin_test_skill(pc, id, true)
        else
          admin_test_skill(pc, id, false)
        end
      rescue
        pc.send_message("Command format is #skill_test <ID>")
      end
    elsif command == "admin_known on"
      Config.check_known = true
    elsif command == "admin_known off"
      Config.check_known = false
    end

    true
  end

  private def admin_test_skill(pc, id, send_msu)
    caster = pc.target.as?(L2Character) || pc

    if skill = SkillData[id, 1]?
      caster.target = pc
      if send_msu
        msu = MagicSkillUse.new(caster, pc, id, 1, skill.hit_time, skill.reuse_delay)
        caster.broadcast_packet(msu)
      else
        caster.do_cast(skill)
      end
    end
  end

  def commands : Enumerable(String)
    {"admin_stats", "admin_skill_test", "admin_known"}
  end
end
