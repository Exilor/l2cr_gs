module AdminCommandHandler::AdminShowQuests
  extend self
  extend AdminCommandHandler

  private STATES = {
    "CREATED",
    "STARTED",
    "COMPLETED"
  }

  def use_admin_command(command, pc)
    cmd_params = command.split
    val = Slice.new(4, "")

    if cmd_params.size > 1
      target = L2World.get_player(cmd_params[1])
      if cmd_params.size > 2
        if cmd_params[2] == "0"
          val[0] = "var"
          val[1] = "Start"
        end
        if cmd_params[2] == "1"
          val[0] = "var"
          val[1] = "Started"
        end
        if cmd_params[2] == "2"
          val[0] = "var"
          val[1] = "Completed"
        end
        if cmd_params[2] == "3"
          val[0] = "full"
        end
        if cmd_params[2].index("_")
          val[0] = "name"
          val[1] = cmd_params[2]
        end
        if cmd_params.size > 3
          if cmd_params[3] == "custom"
            val[0] = "custom"
            val[1] = cmd_params[2]
          end
        end
      end
    else
      target_object = pc.target

      if target_object.is_a?(L2PcInstance)
        target = target_object
      end
    end

    unless target
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      return false
    end

    if command.starts_with?("admin_charquestmenu")
      if val[0].empty?
        show_first_quest_menu(target, pc)
      else
        show_quest_menu(target, pc, val)
      end
    elsif command.starts_with?("admin_setcharquest")
      if cmd_params.size >= 5
        val[0] = cmd_params[2]
        val[1] = cmd_params[3]
        val[2] = cmd_params[4]
        if cmd_params.size == 6
          val[3] = cmd_params[5]
        end
        set_quest_var(target, pc, val)
      else
        return false
      end
    end

    true
  end

  private def show_first_quest_menu(target, actor)
    sb = String::Builder.new
    sb << "<html><body><table width=270><tr><td width=45><button value=\"Main\" action=\"bypass -h admin_admin\" width=45 height=21 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td><td width=180><center>Player: "
    sb << target.name
    sb << "</center></td><td width=45><button value=\"Back\" action=\"bypass -h admin_admin6\" width=45 height=21 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td></tr></table>"
    reply = NpcHtmlMessage.new
    id = target.l2id

    sb << "Quest Menu for <font color=\"LEVEL\">"
    sb << target.name
    sb << "</font> (ID:"
    sb << id
    sb << ")<br><center><table width=250><tr><td><button value=\"CREATED\" action=\"bypass -h admin_charquestmenu "
    sb << target.name
    sb << " 0\" width=85 height=21 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td></tr><tr><td><button value=\"STARTED\" action=\"bypass -h admin_charquestmenu "
    sb << target.name
    sb << " 1\" width=85 height=21 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td></tr><tr><td><button value=\"COMPLETED\" action=\"bypass -h admin_charquestmenu "
    sb << target.name
    sb << " 2\" width=85 height=21 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td></tr><tr><td><br><button value=\"All\" action=\"bypass -h admin_charquestmenu "
    sb << target.name
    sb << " 3\" width=85 height=21 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td></tr><tr><td><br><br>Manual Edit by Quest number:<br></td></tr><tr><td><edit var=\"qn\" width=50 height=15><br><button value=\"Edit\" action=\"bypass -h admin_charquestmenu "
    sb << target.name
    sb << " $qn custom\" width=50 height=21 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td></tr></table></center></body></html>"
    reply.html = sb.to_s
    actor.send_packet(reply)
  end

  private def show_quest_menu(target, actor, val)
    # TODO(Zoey76): Refactor this into smaller methods and separate database access logic from HTML creation.
    id = target.l2id

    sb = String::Builder.new
    sb << "<html><body>"
    reply = NpcHtmlMessage.new

    case val[0]
    when "full"
      sb << "<table width=250><tr><td>Full Quest List for <font color=\"LEVEL\">"
      sb << target.name
      sb << "</font> (ID:"
      sb << id
      sb << ")</td></tr>"

      sql = "SELECT DISTINCT name FROM character_quests WHERE charId=? AND var='<state>' ORDER by name;"
      GameDB.each(sql, id) do |rs|
        sb << "<tr><td><a action=\"bypass -h admin_charquestmenu "
        sb << target.name
        sb << " "
        sb << rs.get_string(:"name")
        sb << "\">"
        sb << rs.get_string(:"name")
        sb << "</a></td></tr>"
      end
      sb << "</table></body></html>"
    when "name"
      qs = target.get_quest_state(val[1])
      state = qs ? STATES[qs.state.to_i] : "CREATED"
      sb << "Character: <font color=\"LEVEL\">"
      sb << target.name
      sb << "</font><br>Quest: <font color=\"LEVEL\">"
      sb << val[1]
      sb << "</font><br>State: <font color=\"LEVEL\">"
      sb << state
      sb << "</font><br><br><center><table width=250><tr><td>Var</td><td>Value</td><td>New Value</td><td>&nbsp;</td></tr>"

      sql = "SELECT var,value FROM character_quests WHERE charId=? AND name=?;"
      GameDB.each(sql, id, val[1]) do |rs|
        var_name = rs.get_string(:"var")
        if var_name == "<state>"
          next
        end
        sb << "<tr><td>"
        sb << var_name
        sb << "</td><td>"
        sb << rs.get_string(:"value")
        sb << "</td><td><edit var=\"var"
        sb << var_name
        sb << "\" width=80 height=15></td><td><button value=\"Set\" action=\"bypass -h admin_setcharquest "
        sb << target.name
        sb << " "
        sb << val[1]
        sb << " "
        sb << var_name
        sb << " $var"
        sb << var_name
        sb << "\" width=30 height=15 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td><td><button value=\"Del\" action=\"bypass -h admin_setcharquest "
        sb << target.name
        sb << " "
        sb << val[1]
        sb << " "
        sb << var_name
        sb << " delete\" width=30 height=15 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td></tr>"
      end
      sb << "</table><br><br><table width=250><tr><td>Repeatable quest:</td><td>Unrepeatable quest:</td></tr><tr><td><button value=\"Quest Complete\" action=\"bypass -h admin_setcharquest "
      sb << target.name
      sb << " "
      sb << val[1]
      sb << " state COMPLETED 1\" width=120 height=21 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td><td><button value=\"Quest Complete\" action=\"bypass -h admin_setcharquest "
      sb << target.name
      sb << " "
      sb << val[1]
      sb << " state COMPLETED 0\" width=120 height=21 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td></tr></table><br><br><font color=\"ff0000\">Delete Quest from DB:</font><br><button value=\"Quest Delete\" action=\"bypass -h admin_setcharquest "
      sb << target.name
      sb << " "
      sb << val[1]
      sb << " state DELETE\" width=120 height=21 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></center></body></html>"
    when "var"
      sb << "Character: <font color=\"LEVEL\">"
      sb << target.name
      sb << "</font><br>Quests with state: <font color=\"LEVEL\">"
      sb << val[1]
      sb << "</font><br><table width=250>"

      sql = "SELECT DISTINCT name FROM character_quests WHERE charId=? and var='<state>' and value=?;"
      GameDB.each(sql, id, val[1]) do |rs|
        sb << "<tr><td><a action=\"bypass -h admin_charquestmenu "
        sb << target.name
        sb << " "
        sb << rs.get_string(:"name")
        sb << "\">"
        sb << rs.get_string(:"name")
        sb << "</a></td></tr>"
      end
      sb << "</table></body></html>"
    when "custom"
      exqdb = true
      exqch = true
      qnumber = val[1].to_i
      state = nil
      qname = nil
      qs = nil

      if quest = QuestManager.get_quest(qnumber)
        qname = quest.name
        qs = target.get_quest_state(qname)
      else
        exqdb = false
      end

      if qs
        state = STATES[qs.state.to_i]
      else
        exqch = false
        state = "N/A"
      end

      if exqdb
        if exqch
          sb << "Character: <font color=\"LEVEL\">"
          sb << target.name
          sb << "</font><br>Quest: <font color=\"LEVEL\">"
          sb << qname
          sb << "</font><br>State: <font color=\"LEVEL\">"
          sb << state
          sb << "</font><br><br><center><table width=250><tr><td>Var</td><td>Value</td><td>New Value</td><td>&nbsp;</td></tr>"

          sql = "SELECT var,value FROM character_quests WHERE charId=? and name=?;"
          GameDB.each(sql, id, qname) do |rs|
            var_name = rs.get_string(:"var")
            if var_name == "<state>"
              next
            end
            sb << "<tr><td>"
            sb << var_name
            sb << "</td><td>"
            sb << rs.get_string(:"value")
            sb << "</td><td><edit var=\"var"
            sb << var_name
            sb << "\" width=80 height=15></td><td><button value=\"Set\" action=\"bypass -h admin_setcharquest "
            sb << target.name
            sb << " "
            sb << qname
            sb << " "
            sb << var_name
            sb << " $var"
            sb << var_name
            sb << "\" width=30 height=15 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td><td><button value=\"Del\" action=\"bypass -h admin_setcharquest "
            sb << target.name
            sb << " "
            sb << qname
            sb << " "
            sb << var_name
            sb << " delete\" width=30 height=15 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td></tr>"
          end
          sb << "</table><br><br><table width=250><tr><td>Repeatable quest:</td><td>Unrepeatable quest:</td></tr><tr><td><button value=\"Quest Complete\" action=\"bypass -h admin_setcharquest "
          sb << target.name
          sb << " "
          sb << qname
          sb << " state COMPLETED 1\" width=100 height=21 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td><td><button value=\"Quest Complete\" action=\"bypass -h admin_setcharquest "
          sb << target.name
          sb << " "
          sb << qname
          sb << " state COMPLETED 0\" width=100 height=21 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td></tr></table><br><br><font color=\"ff0000\">Delete Quest from DB:</font><br><button value=\"Quest Delete\" action=\"bypass -h admin_setcharquest "
          sb << target.name
          sb << " "
          sb << qname
          sb << " state DELETE\" width=100 height=21 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></center></body></html>"
        else
          sb << "Character: <font color=\"LEVEL\">"
          sb << target.name
          sb << "</font><br>Quest: <font color=\"LEVEL\">"
          sb << qname
          sb << "</font><br>State: <font color=\"LEVEL\">"
          sb << state
          sb << "</font><br><br><center>Start this Quest for player:<br><button value=\"Create Quest\" action=\"bypass -h admin_setcharquest "
          sb << target.name
          sb << " "
          sb << qnumber
          sb << " state CREATE\" width=100 height=21 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"><br><br><font color=\"ee0000\">Only for Unrepeateble quests:</font><br><button value=\"Create & Complete\" action=\"bypass -h admin_setcharquest "
          sb << target.name
          sb << " "
          sb << qnumber
          sb << " state CC\" width=130 height=21 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"><br><br></center></body></html>"
        end
      else
        sb << "<center><font color=\"ee0000\">Quest with number </font><font color=\"LEVEL\">"
        sb << qnumber
        sb << "</font><font color=\"ee0000\"> doesn't exist!</font></center></body></html>"
      end
    else
      # [automatically added else]
    end

    reply.html = sb.to_s
    actor.send_packet(reply)
  rescue e
    actor.send_message("There was an error.")
    error e
  end

  private def set_quest_var(target, actor, val)
    qs = target.get_quest_state(val[0])
    outval = Slice.new(3, "")

    if val[1] == "state"
      case val[2]
      when "COMPLETED"
        qs.not_nil!.exit_quest(val[3] == "1")
      when "DELETE"
        qs = qs.not_nil!
        Quest.delete_quest_in_db(qs, true)
        qs.exit_quest(true)
        target.send_packet(QuestList.new)
        target.send_packet(ExShowQuestMark.new(qs.quest.id))
        target.delete_quest_state(qs.quest_name)
        actor.send_message("Removed quest #{qs.quest.descr} from #{target.name}.")
      when "CREATE"
        qs = QuestManager.get_quest(val[0].to_i).not_nil!.new_quest_state(target)
        qs.start_quest
        target.send_packet(QuestList.new)
        target.send_packet(ExShowQuestMark.new(qs.quest.id))
        val[0] = qs.quest.name
      when "CC"
        qs = QuestManager.get_quest(val[0].to_i).not_nil!.new_quest_state(target)
        qs.exit_quest(false)
        target.send_packet(QuestList.new)
        target.send_packet(ExShowQuestMark.new(qs.quest.id))
        val[0] = qs.quest.name
      else
        # [automatically added else]
      end

    else
      qs = qs.not_nil!
      if val[2] == "delete"
        qs.unset(val[1])
      else
        qs.set(val[1], val[2])
      end
      target.send_packet(QuestList.new)
      target.send_packet(ExShowQuestMark.new(qs.quest.id))
    end
    outval[0] = "name"
    outval[1] = val[0]
    show_quest_menu(target, actor, outval)
  end

  def commands
    {"admin_charquestmenu", "admin_setcharquest"}
  end
end
