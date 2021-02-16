module AdminCommandHandler::AdminBuffs
  extend self
  extend AdminCommandHandler

  private PAGE_LIMIT = 20
  private FONT_RED1 = "<font color=\"FF0000\">"
  private FONT_RED2 = "</font>"

  def use_admin_command(command, pc) : Bool
    if command.starts_with?("admin_getbuffs")
      st = command.split
      command = st.shift
      if !st.empty?
        player_name = st.shift
        player = L2World.get_player(player_name)
        if player
          page = 1
          unless st.empty?
            page = st.shift.to_i
          end
          show_buffs(pc, player, page, command.ends_with?("_ps"))
          return true
        end
        pc.send_message("The player #{player_name} is not online.")
        return false
      elsif t = pc.target.as?(L2Character)
        show_buffs(pc, t, 1, command.ends_with?("_ps"))
        return true
      else
        pc.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
        return false
      end
    elsif command.starts_with?("admin_stopbuff")
      begin
        st = command.split

        st.shift
        l2id = st.shift.to_i
        skill_id = st.shift.to_i

        remove_buff(pc, l2id, skill_id)
        return true
      rescue e
        pc.send_message("Failed removing effect: #{e.message}")
        pc.send_message("Usage: #stopbuff <l2id> <skill_id>")
        return false
      end
    elsif command.starts_with?("admin_stopallbuffs")
      begin
        st = command.split
        st.shift
        l2id = st.shift.to_i
        remove_all_buffs(pc, l2id)
        return true
      rescue e
        pc.send_message("Failed removing all effects: #{e.message}")
        pc.send_message("Usage: #stopallbuffs <l2id>")
        return false
      end
    elsif command.starts_with?("admin_areacancel")
      st = command.split
      st.shift
      val = st.shift
      begin
        radius = val.to_i

        pc.known_list.get_known_characters_in_radius(radius) do |char|
          if char.player? && char != pc
            char.stop_all_effects
          end
        end

        pc.send_message("All effects canceled within radius #{radius}")
        return true
      rescue e
        pc.send_message("Usage: #areacancel <radius>")
        return false
      end
    elsif command.starts_with?("admin_removereuse")
      st = command.split
      command = st.shift

      if !st.empty?
        unless creature = L2World.get_player(st.shift)
          pc.send_packet(SystemMessageId::TARGET_IS_NOT_FOUND_IN_THE_GAME)
          return false
        end
      else
        target = pc.target
        if target.is_a?(L2Character)
          creature = target
        end

        unless creature
          pc.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
          return false
        end
      end

      creature.reset_time_stamps
      creature.reset_disabled_skills
      if creature.is_a?(L2PcInstance)
        creature.send_packet(SkillCoolTime.new(creature))
      end
      pc.send_message("Skill reuse was removed from #{creature.name}.")
      return true
    elsif command.starts_with?("admin_switch_gm_buffs")
      if Config.gm_give_special_skills != Config.gm_give_special_aura_skills
        to_aura_skills = !!pc.get_known_skill(7041)
        switch_skills(pc, to_aura_skills)
        pc.send_skill_list
        pc.send_message("You have succefully changed to target " + (to_aura_skills ? "aura" : "one") + " special skills.")
        return true
      end
      pc.send_message("There is nothing to switch.")
      return false
    end

    true
  end

  def switch_skills(gm, to_aura_skills)
    if to_aura_skills
      skills = SkillTreesData.gm_skill_tree.local_each_value
    else
      skills = SkillTreesData.gm_aura_skill_tree.local_each_value
    end
    skills.each do |skill|
      gm.remove_skill(skill, false) # Don't Save GM skills to database
    end
    SkillTreesData.add_skills(gm, to_aura_skills)
  end


  def show_buffs(pc, target, page, passive)
    effects = [] of BuffInfo
    if passive
      target.effect_list.passives.each { |b| effects << b }
    else
      target.effect_list.effects.each { |b| effects << b }
    end

    if page > (effects.size // PAGE_LIMIT) + 1 || page < 1
      return
    end

    max = effects.size // PAGE_LIMIT
    if effects.size > PAGE_LIMIT * max
      max &+= 1
    end

    html = String::Builder.new
    html << "<html><table width=\"100%\"><tr><td width=45><button value=\"Main\" action=\"bypass -h admin_admin\" width=45 height=21 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td><td width=180><center><font color=\"LEVEL\">Effects of "
    html << target.name
    html << "</font></td><td width=45><button value=\"Back\" action=\"bypass -h admin_current_player\" width=45 height=21 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td></tr></table><br><table width=\"100%\"><tr><td width=200>Skill</td><td width=30>Rem. Time</td><td width=70>Action</td></tr>"

    start = (page - 1) * PAGE_LIMIT
    _end = Math.min(((page - 1) * PAGE_LIMIT) + PAGE_LIMIT, effects.size)
    count = 0
    effects.each do |info|
      if count >= start && count < _end
        skill = info.skill
        info.effects.each do |effect|
          html << "<tr><td>"
          unless info.in_use?
            html << FONT_RED1
          end
          html << skill.name
          html << " Lv "
          html << skill.level
          html << " ("
          html << effect.class.simple_name
          html << ")"
          unless info.in_use?
            html << FONT_RED2
          end
          html << "</td><td>"
          if skill.toggle?
            html << "T (#{info.get_tick_count(effect)})"
          else
            if skill.passive?
              html << "P"
            else
              html << info.time
            end
          end
          html << "s"
          html << "</td><td><button value=\"X\" action=\"bypass -h admin_stopbuff "
          html << target.l2id
          html << " "
          html << skill.id
          html << "\" width=30 height=21 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td></tr>"
        end
      end
      count &+= 1
    end

    html << "</table><table width=300 bgcolor=444444><tr>"
    max.times do |x|
      pagenr = x &+ 1
      if page == pagenr
        html << "<td>Page "
        html << pagenr
        html << "</td>"
      else
        html << "<td><a action=\"bypass -h admin_getbuffs"
        html << (passive ? "_ps " : " ")
        html << target.name
        html << " "
        html << pagenr
        html << "\"> Page "
        html << pagenr
        html << " </a></td>"
      end
    end

    html << "</tr></table>"

    # Buttons
    html << "<br><center><button value=\"Refresh\" action=\"bypass -h admin_getbuffs"
    html << (passive ? "_ps " : " ")
    html << target.name
    html << "\" width=80 height=21 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"><button value=\"Remove All\" action=\"bypass -h admin_stopallbuffs "
    html << target.l2id
    html << "\" width=80 height=21 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"><br>"
    # Legend
    unless passive
      html << FONT_RED1
      html << "Inactive buffs: "
      html << target.effect_list.hidden_buffs_count
      html << FONT_RED2
      html << "<br>"
    end
    html << "Total"
    if passive
      html << " passive"
    end
    html << " buff count: "
    html << effects.size
    blocked_buff_slots = target.effect_list.@blocked_buff_slots
    if blocked_buff_slots && blocked_buff_slots.empty?
      html << "<br>Blocked buff slots: "

      slots = String.build do |io|
        target.effect_list.blocked_buff_slots.each do |slot|
          io << slot
          io << ", "
        end
      end

      if !slots.empty? && slots.size > 3
        html << slots[0...slots.size - 2]
      end
    end
    html << "</html>"

    pc.send_packet(NpcHtmlMessage.new(html.to_s))

    if Config.gmaudit
      GMAudit.log(pc, "getbuffs", "#{target.name} (#{target.l2id})", "")
    end
  end

  private def remove_buff(pc, l2id, skill_id)
    unless target = L2World.find_object(l2id).as?(L2Character)
      return
    end

    if target && skill_id > 0
      if target.affected_by_skill?(skill_id)
        target.stop_skill_effects(true, skill_id)
        pc.send_message("Removed skill ID: #{skill_id} effects from #{target.name} (#{l2id}).")
      end

      show_buffs(pc, target, 1, false)
      if Config.gmaudit
        GMAudit.log(pc, "stopbuff", "#{target.name} (#{l2id})", skill_id.to_s)
      end
    end
  end

  private def remove_all_buffs(pc, l2id)
    if target = L2World.find_object(l2id).as?(L2Character)
      target.stop_all_effects
      pc.send_message("Removed all effects from #{target.name} (#{l2id})")
      show_buffs(pc, target, 1, false)
      if Config.gmaudit
        GMAudit.log(pc, "stopallbuffs", "#{target.name} (#{l2id})", "")
      end
    end
  end

  def commands
    {
      "admin_getbuffs",
      "admin_getbuffs_ps",
      "admin_stopbuff",
      "admin_stopallbuffs",
      "admin_areacancel",
      "admin_removereuse",
      "admin_switch_gm_buffs"
    }
  end
end
