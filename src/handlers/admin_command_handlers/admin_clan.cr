module AdminCommandHandler::AdminClan
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    st = command.split
    cmd = st.shift
    case cmd
    when "admin_clan_info"
      unless player = get_player(pc, st)
        return true
      end

      unless clan = player.clan?
        pc.send_packet(SystemMessageId::TARGET_MUST_BE_IN_CLAN)
        return false
      end

      html = Packets::Outgoing::NpcHtmlMessage.new(0, 1)
      html.html = HtmCache.get_htm(pc, "data/html/admin/claninfo.htm").not_nil!
      html["%clan_name%"] = clan.name
      html["%clan_leader%"] = clan.leader_name
      html["%clan_level%"] = clan.level
      if clan.castle_id > 0
        html["%clan_has_castle%"] = CastleManager.get_castle_by_id!(clan.castle_id).name
      else
        html["%clan_has_castle%"] = "No"
      end

      if clan.hideout_id > 0
        html["%clan_has_clanhall%"] = ClanHallManager.get_clan_hall_by_id!(clan.hideout_id).name
      else
        html["%clan_has_clanhall%"] = "No"
      end

      if clan.fort_id > 0
        html["%clan_has_fortress%"] = FortManager.get_fort_by_id!(clan.fort_id).name
      else
        html["%clan_has_fortress%"] = "No"
      end

      html["%clan_points%"] = clan.reputation_score
      html["%clan_players_count%"] = clan.members_count
      html["%clan_ally%"] = clan.ally_id > 0 ? clan.ally_name : "Not in ally"
      html["%current_player_objectId%"] = player.l2id
      html["%current_player_name%"] = player.name
      pc.send_packet(html)
      return true
    when "admin_clan_changeleader"
      unless player = get_player(pc, st)
        return true
      end


      unless clan = player.clan?
        pc.send_packet(SystemMessageId::TARGET_MUST_BE_IN_CLAN)
        return false
      end

      if member = clan.get_clan_member(player.l2id)
        if player.academy_member?
          player.send_packet(SystemMessageId::RIGHT_CANT_TRANSFERRED_TO_ACADEMY_MEMBER)
        else
          clan.set_new_leader(member)
        end
      end
    when "admin_clan_show_pending"
      html = Packets::Outgoing::NpcHtmlMessage.new(0, 1)
      html.html = HtmCache.get_htm(pc, "data/html/admin/clanchanges.htm").not_nil!
      sb = String.build do |io|
        ClanTable.clans.each do |clan|
          if clan.new_leader_id != 0
            io << "<tr>"
            io << "<td>"
            io << clan.name
            io << "</td>"
            io << "<td>"
            io << clan.new_leader_name
            io << "</td>"
            io << "<td><a action=\"bypass -h admin_clan_force_pending "
            io << clan.id
            io << "\">Force</a></td>"
            io << "</tr>"
          end
        end
      end
      html["%data%"] = sb
      pc.send_packet(html)
    when "admin_clan_force_pending"
      unless st.empty?
        token = st.shift
        unless token.num?
          return true
        end
        clan_id = token.to_i

        unless clan = ClanTable.get_clan(clan_id)
          return true
        end

        unless member = clan.get_clan_member(clan.new_leader_id)
          return true
        end

        clan.set_new_leader(member)
        pc.send_message("Task have been forcely executed.")
      end
    end

    true
  end

  private def get_player(pc, st)
    if !st.empty?
      val = st.shift
      if val.num?
        unless player = L2World.get_player(val.to_i)
          pc.send_packet(SystemMessageId::TARGET_IS_NOT_FOUND_IN_THE_GAME)
          return
        end
      else
        unless player = L2World.get_player(val)
          pc.send_packet(SystemMessageId::INCORRECT_NAME_TRY_AGAIN)
          return
        end
      end
    else
      unless player = pc.target.as?(L2PcInstance)
        pc.send_packet(SystemMessageId::INCORRECT_TARGET)
        return
      end
    end

    player
  end

  def commands
    {
      "admin_clan_info",
      "admin_clan_changeleader",
      "admin_clan_show_pending",
      "admin_clan_force_pending"
    }
  end
end
