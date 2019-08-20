module AdminCommandHandler::AdminSkill
  extend self
  extend AdminCommandHandler

  @@admin_skills : Slice(Skill)?

  def use_admin_command(command, pc)
    if command == "admin_show_skills"
      show_main_page(pc)
    elsif command.starts_with?("admin_remove_skills")
      val = command.from(20)
      remove_skills_page(pc, val.to_i)
    elsif command.starts_with?("admin_skill_list")
      AdminHtml.show_admin_html(pc, "skills.htm")
    elsif command.starts_with?("admin_skill_index")
      val = command.from(18)
      AdminHtml.show_admin_html(pc, "skills/#{val}.htm")
    elsif command.starts_with?("admin_add_skill")
      val = command.from(15)
      admin_add_skill(pc, val)
    elsif command.starts_with?("admin_remove_skill")
      id = command.from(19)
      if id.num?
        admin_remove_skill(pc, id.to_i)
      else
        pc.send_message("Usage: //remove_skill <skill_id>")
      end
    elsif command == "admin_get_skills"
      admin_get_skills(pc)
    elsif command == "admin_reset_skills"
			admin_reset_skills(pc)
    elsif command == "admin_give_all_skills"
			admin_give_all_skills(pc, false)
    elsif command == "admin_give_all_skills_fs"
			admin_give_all_skills(pc, true)
    elsif command == "admin_give_clan_skills"
			admin_give_clan_skills(pc, false)
    elsif command == "admin_give_all_clan_skills"
			admin_give_clan_skills(pc, true)
    elsif command == "admin_remove_all_skills"
      unless target = pc.target.as?(L2PcInstance)
        pc.send_packet(SystemMessageId::INCORRECT_TARGET)
        return false
      end
      target.all_skills.each { |sk| target.remove_skill(sk) }
      pc.send_message("You have removed all skills from #{target.name}.")
      pc.send_message("Admin removed all skills from you.")
      pc.send_skill_list
      pc.broadcast_user_info
    elsif command.starts_with?("admin_add_clan_skill")
      begin
        val = command.split
        if val.size == 3 && val[1].num? && val[2].num?
          admin_add_clan_skill(pc, val[1].to_i, val[2].to_i)
        else
          pc.send_message("Usage: //add_clan_skill <skill_id> <level>")
        end
      end
    elsif command.starts_with?("admin_setskill")
      split = command.split
      id = split[1].to_i
      lvl = split[2].to_i
      skill = SkillData[id, lvl]
      pc.add_skill(skill)
      pc.send_skill_list
      pc.send_message("You added yourself skill #{skill.name} (#{id}) level #{lvl}")
    end

    true
  end

  private def admin_give_all_skills(pc, include_fs)
    target = pc.target
    unless target.is_a?(L2PcInstance)
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      return
    end

    pc.send_message("You gave #{pc.give_available_skills(include_fs, true)} skills to #{target.name}")
    target.send_skill_list
  end

  private def admin_give_clan_skills(pc, include_squad)
    warn "#admin_give_clan_skills: not done"
  end

  private def remove_skills_page(pc, page)
    target = pc.target
    unless target.is_a?(L2PcInstance)
      pc.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
      return
    end

    skills = pc.all_skills.to_a
    max_skills_per_page = 10
    max_pages = skills.size / max_skills_per_page

    if skills.size > max_skills_per_page * max_pages
      max_pages += 1
    end

    if page > max_pages
      page = max_pages
    end

    skills_start = max_skills_per_page * page
    skills_end = skills.size

    if skills_end - skills_start > max_skills_per_page
      skills_end = skills_start + max_skills_per_page
    end

    admin_reply = Packets::Outgoing::NpcHtmlMessage.new
    msg_size = 500 + (max_pages * 50) + (((skills_end - skills_start) + 1) * 50)
    msg = String.build(msg_size) do |io|
      io << "<html><body><table width=260><tr><td width=40><button value"
      io << "=\"Main\" action=\"bypass -h admin_admin\" width=40 height=15"
      io << " back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td>"
      io << "<td width=180><center>Character Selection Menu</center></td><td"
      io << " width=40><button value=\"Back\" action=\"bypass -h"
      io << " admin_show_skills\" width=40 height=15 back=\"L2UI_ct1.button_"
      io << "df\" fore=\"L2UI_ct1.button_df\"></td></tr></table><br><br><center"
      io << ">Editing <font color=\"LEVEL\">"
      io << pc.name
      io << "</font></center><br>"
      io << "<table width=270><tr><td>Lv: "
      io << pc.level
      io << " "
      ClassListData.get_class!(pc.class_id).client_code(io)
      io << "</td></tr></table><br>"
      io << "<table width=270><tr><td>Note: Dont forget that modifying players "
      io << "skills can</td></tr><tr><td>ruin the game...</td></tr></table><br>"
      io << "<center>Click on the skill you wish to remove:</center><br><center>"
      io << "<table width=270><tr>"
      max_pages.times do |x|
        io << "<td><a action=\"bypass -h admin_remove_skills "
        io << x
        io << "\">Page "
        io << x + 1
        io << "</a></td>"
      end
      io << "</tr></table></center><br><table width=270><tr><td width=80>Name:"
      io << "</td><td width=60>Level:</td><td width=40>Id:</td></tr>"
      (skills_start...skills_end).each do |i|
        io << "<tr><td width=80><a action=\"bypass -h admin_remove_skill "
        io << skills[i].id
        io << "\">"
        io << skills[i].name
        io << "</a></td><td width=60>"
        io << skills[i].level
        io << "</td><td width=40>"
        io << skills[i].id
        io << "</td></tr>"
      end
      io << "</table><br><center><table>Remove skill by ID :<tr><td>Id: </td>"
      io << "<td><edit var=\"id_to_remove\" width=110></td></tr></table>"
      io << "</center><center><button value=\"Remove skill\" action=\"bypass -h"
      io << " admin_remove_skill $id_to_remove\" width=110 height=15 back=\"L2U"
      io << "I_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></center><br><center>"
      io << "<button value=\"Back\" action=\"bypass -h admin_current_player\" "
      io << "width=40 height=15 back=\"L2UI_ct1.button_df\"fore=\"L2UI_ct1.butt"
      io << "on_df\"></center>"
      io << "</body></html>"
    end
    admin_reply.html = msg
    pc.send_packet(admin_reply)
  end

  private def show_main_page(pc : L2PcInstance)
    target = pc.target
    unless target.is_a?(L2PcInstance)
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      return
    end

    reply = Packets::Outgoing::NpcHtmlMessage.new
    reply.set_file(pc, "data/html/admin/charskills.htm")
    reply["%name%"] = target.name
    reply["%level%"] = target.level
    reply["%class%"] = ClassListData.get_class!(target.class_id).client_code
    pc.send_packet(reply)
  end

  private def admin_get_skills(pc)
    unless player = pc.target.as?(L2PcInstance)
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      return
    end

    if pc == player
      pc.send_packet(SystemMessageId::CANNOT_USE_ON_YOURSELF)
    else
      skills = pc.all_skills
      admin_skills = player.all_skills
      admin_skills.each do |skill|
        pc.remove_skill(skill)
      end

      skills.each do |skill|
        pc.add_skill(skill, true)
      end

      pc.send_message("You now have all the skills of #{player.name}.")
      pc.send_skill_list
    end

    show_main_page(pc)
  end

  private def admin_reset_skills(pc)
    unless player = pc.target.as?(L2PcInstance)
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      return
    end

    admin_skills = @@admin_skills
    if admin_skills.nil?
      pc.send_message("You must copy the skills of someone else in order to do this.")
    else
      skills = player.all_skills
      skills.each do |skill|
        player.remove_skill(skill)
      end
      pc.all_skills.each do |skill|
        player.add_skill(skill, true)
      end
      skills.each do |skill|
        pc.remove_skill(skill)
      end
      admin_skills.each do |skill|
        pc.add_skill(skill, true)
      end
      player.send_message("GM #{pc.name} updated your skills.")
      pc.send_message("You now have all your skills back.")
      @@admin_skills = nil
      pc.send_skill_list
      player.send_skill_list
    end

    show_main_page(pc)
  end

  private def admin_add_skill(pc, val)
    unless player = pc.target.as?(L2PcInstance)
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      return
    end

    st = val.split
    if st.size != 2
      show_main_page(pc)
    else
      begin
        id = st.shift.to_i
        level = st.shift.to_i
        skill = SkillData[id, level]?
      rescue e
        error e
      end

      if skill
        name = skill.name
        pc.send_message("Admin gave you the skill #{name}.")
        pc.add_skill(skill, true)
        pc.send_skill_list
        pc.send_message("You have the skill #{name} to #{player.name}.")
        debug { "GM #{pc.name} gave skill #{name} to #{player.name}." }
        pc.send_skill_list
      else
        pc.send_message("Error: there is no such skill.")
      end

      show_main_page(pc)
    end
  end

  private def admin_remove_skill(pc, id)
    unless player = pc.target.as?(L2PcInstance)
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      return
    end

    if skill = SkillData[id, player.get_skill_level(id)]?
      name = skill.name
      pc.send_message("GM #{pc.name} removed skill #{name} from your skill list.")
      pc.remove_skill(skill)
      pc.send_message("You removed the skill #{name} from #{player.name}.")
      debug { "GM #{pc.name} removed skill #{name} from #{player.name}." }
      pc.send_skill_list
    else
      pc.send_message("Error: no such skill.")
    end

    remove_skills_page(pc, 0)
  end

  private def admin_add_clan_skill(pc, id, level)
    unless player = pc.target.as?(L2PcInstance)
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      return
    end

    unless player.clan_leader?
      sm = Packets::Outgoing::SystemMessage.s1_is_not_a_clan_leader
      sm.add_string(player.name)
      pc.send_packet(sm)
      show_main_page(pc)
      return
    end
    if id < 370 || id > 391 || level < 1 || level > 3
      pc.send_message("Usage: //add_clan_skill <skill_id> <level>")
      show_main_page(pc)
      return
    end

    unless skill = SkillData[id, level]?
      pc.send_message("Error: there is no such skill.")
      return
    end

    name = skill.name
    sm = Packets::Outgoing::SystemMessage.clan_skill_s1_added
    sm.add_skill_name(skill)
    player.send_packet(sm)
    clan = player.clan
    clan.broadcast_to_online_members(sm)
    clan.add_new_skill(skill)
    pc.send_message("You gave the Clan Skill: #{name} to the clan #{clan.name}.")

    clan.broadcast_to_online_members(Packets::Outgoing::PledgeSkillList.new(clan))
    clan.each_online_player do |m|
      m.send_skill_list
    end

    show_main_page(pc)
  end

  def commands
    {
      "admin_show_skills",
  		"admin_remove_skills",
  		"admin_skill_list",
  		"admin_skill_index",
  		"admin_add_skill",
  		"admin_remove_skill",
  		"admin_get_skills",
  		"admin_reset_skills",
  		"admin_give_all_skills",
  		"admin_give_all_skills_fs",
  		"admin_give_clan_skills",
  		"admin_give_all_clan_skills",
  		"admin_remove_all_skills",
  		"admin_add_clan_skill",
  		"admin_setskill"
    }
  end
end
