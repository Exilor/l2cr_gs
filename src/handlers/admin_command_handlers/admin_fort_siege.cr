module AdminCommandHandler::AdminFortSiege
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    st = command.split
    command = st.shift

    fort_id = 0
    unless st.empty?
      fort_id = st.shift.to_i
      fort = FortManager.get_fort_by_id(fort_id)
    end

    if fort.nil? || fort_id == 0
      show_fort_select_page(pc)
    else
      target = pc.target
      if target.is_a?(L2PcInstance)
        player = target
      end

      if command.casecmp?("admin_add_fortattacker")
        if player.nil?
          pc.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
        else
          if fort.siege.add_attacker(player, false) == 4
            sm = SystemMessage.registered_to_s1_fortress_battle
            sm.add_castle_id(fort.residence_id)
            player.send_packet(sm)
          else
            player.send_message("Error occurred during registration")
          end
        end
      elsif command.casecmp?("admin_clear_fortsiege_list")
        fort.siege.clear_siege_clan
      elsif command.casecmp?("admin_endfortsiege")
        fort.siege.end_siege
      elsif command.casecmp?("admin_list_fortsiege_clans")
        pc.send_message("Not implemented yet")
      elsif command.casecmp?("admin_setfort")
        if clan = player.try &.clan
          fort.end_of_siege(clan)
        else
          pc.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
        end
      elsif command.casecmp?("admin_removefort")
        if fort.owner_clan?
          fort.remove_owner(true)
        else
          pc.send_message("Unable to remove fort")
        end
      elsif command.casecmp?("admin_spawn_fortdoors")
        fort.reset_doors
      elsif command.casecmp?("admin_startfortsiege")
        fort.siege.start_siege
      end

      show_fort_siege_page(pc, fort)
    end

    true
  end

  private def show_fort_select_page(pc)
    i = 0
    reply = NpcHtmlMessage.new
    reply.set_file(pc, "data/html/admin/forts.htm")
    forts = FortManager.forts
    list = String.build(forts.size &* 100) do |io|
      forts.each do |fort|
        io << "<td fixwidth=90><a action=\"bypass -h admin_fortsiege "
        io << fort.residence_id
        io << "\">"
        io << fort.name
        io << " id: "
        io << fort.residence_id
        io << "</a></td>"
        i &+= 1

        if i > 2
          io << "</tr><tr>"
          i = 0
        end
      end
    end

    reply["%forts%"]= list
    pc.send_packet(reply)
  end

  private def show_fort_siege_page(pc, fort)
    reply = NpcHtmlMessage.new
    reply.set_file(pc, "data/html/admin/fort.htm")
    reply["%fortName%"] = fort.name
    reply["%fortId%"] = fort.residence_id
    pc.send_packet(reply)
  end

  def commands : Enumerable(String)
    {
      "admin_fortsiege",
      "admin_add_fortattacker",
      "admin_list_fortsiege_clans",
      "admin_clear_fortsiege_list",
      "admin_spawn_fortdoors",
      "admin_endfortsiege",
      "admin_startfortsiege",
      "admin_setfort",
      "admin_removefort"
    }
  end
end
