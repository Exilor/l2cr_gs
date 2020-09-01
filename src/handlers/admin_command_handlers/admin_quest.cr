module AdminCommandHandler::AdminQuest
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    if command.starts_with?("admin_quest_reload")
      pc.send_message("admin_quest_reload is not implemented.")
    elsif command.starts_with?("admin_script_load")
      pc.send_message("admin_script_load is not implemented.")
    elsif command.starts_with?("admin_script_unload")
      pc.send_message("admin_script_unload is not implemented.")
    elsif command.starts_with?("admin_show_quests")
      if char = pc.target.as?(L2Character)
        sb = String::Builder.new
        quest_names = Set(String).new
        EventType.each do |type|
          char.get_listeners(type).each do |listener|
            if quest = listener.owner.as?(Quest)
              if quest_names.includes?(quest.name)
                next
              end

              sb << "<tr><td colspan=\"4\"><font color=\"LEVEL\"><a action=\"bypass -h admin_quest_info "
              sb << quest.name
              sb << "\">"
              sb << quest.name
              sb << "</a></font></td></tr>"

              quest_names << quest.name
            end
          end
        end

        msg = NpcHtmlMessage.new(0, 1)
        msg.set_file(pc, "data/html/admin/npc-quests.htm")
        msg["%quests%"] = sb.to_s
        msg["%objid%"] = char.l2id
        msg["%questName%"] = ""

        pc.send_packet(msg)
      else
        pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      end
    elsif command.starts_with?("admin_quest_info")
      quest_name = command.from("admin_quest_info ".size) rescue ""
      unless quest = QuestManager.get_quest(quest_name)
        pc.send_message("Couldn't find quest or script with name \"#{quest_name}\".")
        return false
      end

      events = npcs = items = timers = ""
      counter = 0

      listener_types = Set(EventType).new

      quest.listeners.each do |listener|
        unless listener_types.includes?(listener.type)
          events += ", #{listener.type}"
          listener_types << listener.type
          counter &+= 1
        end

        if counter > 10
          counter = 0
          break
        end
      end

      npc_ids = quest.get_registered_ids(ListenerRegisterType::NPC)

      npc_ids.each do |npc_id|
        npcs += ", #{npc_id}"
        counter &+= 1
        if counter > 50
          counter = 0
          break
        end
      end

      unless events.empty?
        events = "#{listener_types.size}: #{events.from(2)}"
      end

      unless npcs.empty?
        npcs = "#{npc_ids.size}: #{npcs.from(2)}"
      end

      quest.registered_item_ids.each do |item_id|
        items += ", #{item_id}"
        counter &+= 1
        if counter > 20
          counter = 0
          break
        end
      end

      items = "#{quest.registered_item_ids.size}: #{items.from(2)}"

      quest.quest_timers.each_value do |list|
        list.each do |timer|
          timers += "<tr><td colspan=\"4\"><table width=270 border=0 bgcolor=131210><tr><td width=270><font color=\"LEVEL\">#{timer.name}:</font> <font color=00FF00>Active: #{timer.active?} Repeatable: #{timer.repeating?} Player: #{timer.player} Npc: #{timer.npc}</font></td></tr></table></td></tr>"
          counter &+= 1
          if counter > 10
            break
          end
        end
      end

      sb = String::Builder.new
      sb << "<tr><td colspan=\"4\"><table width=270 border=0 bgcolor=131210><tr><td width=270><font color=\"LEVEL\">ID:</font> <font color=00FF00>"
      sb << quest.id
      sb << "</font></td></tr></table></td></tr>"
      sb << "<tr><td colspan=\"4\"><table width=270 border=0 bgcolor=131210><tr><td width=270><font color=\"LEVEL\">Name:</font> <font color=00FF00>"
      sb << quest.name
      sb << "</font></td></tr></table></td></tr>"
      sb << "<tr><td colspan=\"4\"><table width=270 border=0 bgcolor=131210><tr><td width=270><font color=\"LEVEL\">Descr:</font> <font color=00FF00>"
      sb << quest.description
      sb << "</font></td></tr></table></td></tr>"
      sb << "<tr><td colspan=\"4\"><table width=270 border=0 bgcolor=131210><tr><td width=270><font color=\"LEVEL\">Path:</font> <font color=00FF00>"
      sb << quest.class.name
      sb << "</font></td></tr></table></td></tr>"
      sb << "<tr><td colspan=\"4\"><table width=270 border=0 bgcolor=131210><tr><td width=270><font color=\"LEVEL\">Events:</font> <font color=00FF00>"
      sb << events
      sb << "</font></td></tr></table></td></tr>"
      unless npcs.empty?
        sb << "<tr><td colspan=\"4\"><table width=270 border=0 bgcolor=131210><tr><td width=270><font color=\"LEVEL\">NPCs:</font> <font color=00FF00>"
        sb << npcs
        sb << "</font></td></tr></table></td></tr>"
      end
      unless items.empty?
        sb << "<tr><td colspan=\"4\"><table width=270 border=0 bgcolor=131210><tr><td width=270><font color=\"LEVEL\">Items:</font> <font color=00FF00>"
        sb << items
        sb << "</font></td></tr></table></td></tr>"
      end
      unless timers.empty?
        sb << "<tr><td colspan=\"4\"><table width=270 border=0 bgcolor=131210><tr><td width=270><font color=\"LEVEL\">Timers:</font> <font color=00FF00></font></td></tr></table></td></tr>"
        sb << timers
      end

      msg = NpcHtmlMessage.new(0, 1)
      msg.set_file(pc, "data/html/admin/npc-quests.htm")
      msg["%quests%"] = sb.to_s
      msg["%questName%"] = "<table><tr><td width=\"50\" align=\"left\"><a action=\"bypass -h admin_script_load #{quest.name}\">Reload</a></td> <td width=\"150\"  align=\"center\"><a action=\"bypass -h admin_quest_info #{quest.name}\">#{quest.name}</a></td> <td width=\"50\" align=\"right\"><a action=\"bypass -h admin_script_unload #{quest.name}\">Unload</a></tr></td></table>"
      pc.send_packet(msg)
    end

    true
  end

  def commands
    {
      "admin_quest_reload",
      "admin_script_load",
      "admin_script_unload",
      "admin_show_quests",
      "admin_quest_info"
    }
  end
end
