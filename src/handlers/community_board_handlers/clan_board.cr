module CommunityBoardHandler::ClanBoard
  extend self
  extend IParseBoardHandler

  def parse_command(command, pc)
    if command == "_bbsclan"
      CommunityBoardHandler.add_bypass(pc, "Clan", command)
      clan = pc.clan
      if clan.nil? || clan.level < 2
        clan_list(pc, 1)
      else
        clan_home(pc)
      end
    elsif command.starts_with?("_bbsclan_clanlist")
      CommunityBoardHandler.add_bypass(pc, "Clan List", command)

      if command == "_bbsclan_clanlist"
        clan_list(pc, 1)
      elsif command.starts_with?("_bbsclan_clanlist")
        begin
          clan_list(pc, command.split(';')[1].to_i)
        rescue e
          clan_list(pc, 1)
          warn e
        end
      end
    elsif command.starts_with?("_bbsclan_clanhome")
      CommunityBoardHandler.add_bypass(pc, "Clan Home", command)

      if command == "_bbsclan_clanhome"
        clan_home(pc)
      elsif command.starts_with?("_bbsclan_clanhome;")
        begin
          clan_home(pc, command.split(';')[1].to_i)
        rescue e
          clan_home(pc)
          warn e
        end
      end
    elsif command.starts_with?("_bbsclan_clannotice_edit")
      CommunityBoardHandler.add_bypass(pc, "Clan Edit", command)
      clan_notice(pc, pc.clan_id)
    elsif command.starts_with?("_bbsclan_clannotice_enable")
      CommunityBoardHandler.add_bypass(pc, "Clan Notice Enable", command)

      if clan = pc.clan
        clan.notice_enabled = true
      end
      clan_notice(pc, pc.clan_id)
    elsif command.starts_with?("_bbsclan_clannotice_disable")
      CommunityBoardHandler.add_bypass(pc, "Clan Notice Disable", command)

      if clan = pc.clan
        clan.notice_enabled = false
      end
      clan_notice(pc, pc.clan_id)
    else
      CommunityBoardHandler.separate_and_send("<html><body><br><br><center>Command #{command} need development.</center><br><br></body></html>", pc)
    end

    true
  end

  private def clan_notice(pc, clan_id)
    unless clan = ClanTable.get_clan(clan_id)
      return
    end

    if clan.level < 2
      pc.send_packet(SystemMessageId::NO_CB_IN_MY_CLAN)
      parse_command("_bbsclan_clanlist", pc)
    else
      parts = Array(String | Int32).new
      parts << "<html><body><br><br><table border=0 width=610><tr><td width=10></td><td width=600 align=left><a action=\"bypass _bbshome\">HOME</a> &gt; <a action=\"bypass _bbsclan_clanlist\"> CLAN COMMUNITY </a>  &gt; <a action=\"bypass _bbsclan_clanhome;"
      parts << clan_id << "\"> &amp;$802; </a></td></tr></table>"

      if pc.clan_leader? && (clan = pc.clan)
        parts << "<br><br><center><table width=610 border=0 cellspacing=0 cellpadding=0><tr><td fixwidth=610><font color=\"AAAAAA\">The Clan Notice function allows the clan leader to send messages through a pop-up window to clan members at login.</font> </td></tr><tr><td height=20></td></tr>"
        if clan.notice_enabled?
          parts << "<tr><td fixwidth=610> Clan Notice Function:&nbsp;&nbsp;&nbsp;on&nbsp;&nbsp;&nbsp;/&nbsp;&nbsp;&nbsp;<a action=\"bypass _bbsclan_clannotice_disable\">off</a>"
        else
          parts << "<tr><td fixwidth=610> Clan Notice Function:&nbsp;&nbsp;&nbsp;<a action=\"bypass _bbsclan_clannotice_enable\">on</a>&nbsp;&nbsp;&nbsp;/&nbsp;&nbsp;&nbsp;off"
        end

        parts << "</td></tr></table><img src=\"L2UI.Squaregray\" width=\"610\" height=\"1\"><br> <br><table width=610 border=0 cellspacing=2 cellpadding=0><tr><td>Edit Notice: </td></tr><tr><td height=5></td></tr><tr><td><MultiEdit var =\"Content\" width=610 height=100></td></tr></table><br><table width=610 border=0 cellspacing=0 cellpadding=0><tr><td height=5></td></tr><tr><td align=center FIXWIDTH=65><button value=\"&$140;\" action=\"Write Notice Set _ Content Content Content\" back=\"l2ui_ch3.smallbutton2_down\" width=65 height=20 fore=\"l2ui_ch3.smallbutton2\" ></td><td align=center FIXWIDTH=45></td><td align=center FIXWIDTH=500></td></tr></table></center></body></html>"

        Util.send_cb_html(pc, parts.join, clan.notice)
      else
        parts << "<img src=\"L2UI.squareblank\" width=\"1\" height=\"10\"><center><table border=0 cellspacing=0 cellpadding=0><tr><td>You are not your clan's leader, and therefore cannot change the clan notice</td></tr></table>"
        if (clan = pc.clan.not_nil!).notice_enabled?
          parts << "<table border=0 cellspacing=0 cellpadding=0><tr><td>The current clan notice:</td></tr><tr><td fixwidth=5></td><td FIXWIDTH=600 align=left>"
          parts << clan.notice
          parts << "</td><td fixqqwidth=5></td></tr></table>"
        end
        parts << "</center></body></html>"
        CommunityBoardHandler.separate_and_send(parts.join, pc)
      end
    end
  end

  private def clan_list(pc, index)
    if index < 1
      index = 1
    end

    html = String.build(2000) do |io|
      io << "<html><body><br><br><center><br1><br1><table border=0 cellspacing=0 cellpadding=0><tr><td FIXWIDTH=15>&nbsp;</td><td width=610 height=30 align=left><a action=\"bypass _bbsclan_clanlist\"> CLAN COMMUNITY </a></td></tr></table><table border=0 cellspacing=0 cellpadding=0 width=610 bgcolor=434343><tr><td height=10></td></tr><tr><td fixWIDTH=5></td><td fixWIDTH=600><a action=\"bypass _bbsclan_clanhome;"
      io << (pc.clan.try &.id || 0)
      io << "\">[GO TO MY CLAN]</a>&nbsp;&nbsp;</td><td fixWIDTH=5></td></tr><tr><td height=10></td></tr></table><br><table border=0 cellspacing=0 cellpadding=2 bgcolor=5A5A5A width=610><tr><td FIXWIDTH=5></td><td FIXWIDTH=200 align=center>CLAN NAME</td><td FIXWIDTH=200 align=center>CLAN LEADER</td><td FIXWIDTH=100 align=center>CLAN LEVEL</td><td FIXWIDTH=100 align=center>CLAN MEMBERS</td><td FIXWIDTH=5></td></tr></table><img src=\"L2UI.Squareblank\" width=\"1\" height=\"5\">"

      ClanTable.clans.each_with_index do |clan, i|
        if i > ((index &+ 1) &* 7)
          break
        end

        if i >= ((index &- 1) &* 7)
          io << "<img src=\"L2UI.SquareBlank\" width=\"610\" height=\"3\"><table border=0 cellspacing=0 cellpadding=0 width=610><tr> <td FIXWIDTH=5></td><td FIXWIDTH=200 align=center><a action=\"bypass _bbsclan_clanhome;"
          io << clan.id
          io << "\">"
          io << clan.name
          io << "</a></td><td FIXWIDTH=200 align=center>"
          io << clan.leader_name
          io << "</td><td FIXWIDTH=100 align=center>"
          io << clan.level
          io << "</td><td FIXWIDTH=100 align=center>"
          io << clan.size
          io << "</td><td FIXWIDTH=5></td></tr><tr><td height=5></td></tr></table><img src=\"L2UI.SquareBlank\" width=\"610\" height=\"3\"><img src=\"L2UI.SquareGray\" width=\"610\" height=\"1\">"
        end
      end

      io << "<img src=\"L2UI.SquareBlank\" width=\"610\" height=\"2\"><table cellpadding=0 cellspacing=2 border=0><tr>"

      if index == 1
        io << "<td><button action=\"\" back=\"l2ui_ch3.prev1_down\" fore=\"l2ui_ch3.prev1\" width=16 height=16 ></td>"
      else
        io << "<td><button action=\"_bbsclan_clanlist;"
        io << (index &- 1)
        io << "\" back=\"l2ui_ch3.prev1_down\" fore=\"l2ui_ch3.prev1\" width=16 height=16 ></td>"
      end

      nbp = ClanTable.clan_count // 8
      if nbp &* 8 != ClanTable.clan_count
        nbp &+= 1
      end

      1.upto(nbp) do |i|
        if i == index
          io << "<td> " << i << " </td>"
        else
          io << "<td><a action=\"bypass _bbsclan_clanlist;"
          io << i
          io << "\"> "
          io << " </a></td>"
        end
      end

      if index == nbp
        io << "<td><button action=\"\" back=\"l2ui_ch3.next1_down\" fore=\"l2ui_ch3.next1\" width=16 height=16 ></td>"
      else
        io << "<td><button action=\"bypass _bbsclan_clanlist;"
        io << (index &+ 1)
        io << "\" back=\"l2ui_ch3.next1_down\" fore=\"l2ui_ch3.next1\" width=16 height=16 ></td>"
      end

      io << "</tr></table><table border=0 cellspacing=0 cellpadding=0><tr><td width=610><img src=\"sek.cbui141\" width=\"610\" height=\"1\"></td></tr></table><table border=0><tr><td><combobox width=65 var=keyword list=\"Name;Ruler\"></td><td><edit var = \"Search\" width=130 height=11 length=\"16\"></td>"
      # L2J TODO: Write in BBS
      io << "<td><button value=\"&$420;\" action=\"Write 5 -1 0 Search keyword keyword\" back=\"l2ui_ch3.smallbutton2_down\" width=65 height=20 fore=\"l2ui_ch3.smallbutton2\"> </td> </tr></table><br><br></center></body></html>"
    end

    CommunityBoardHandler.separate_and_send(html, pc)
  end

  private def clan_home(pc : L2PcInstance)
    clan_home(pc, pc.clan.not_nil!.id)
  end

  private def clan_home(pc : L2PcInstance, clan_id : Int32)
    unless clan = ClanTable.get_clan(clan_id)
      return
    end

    if clan.level < 2
      pc.send_packet(SystemMessageId::NO_CB_IN_MY_CLAN)
      parse_command("_bbsclan_clanlist", pc)
    else
      html = String.build do |io|
        io << "<html><body><center><br><br><br1><br1><table border=0 cellspacing=0 cellpadding=0><tr><td FIXWIDTH=15>&nbsp;</td><td width=610 height=30 align=left><a action=\"bypass _bbshome\">HOME</a> &gt; <a action=\"bypass _bbsclan_clanlist\"> CLAN COMMUNITY </a>  &gt; <a action=\"bypass _bbsclan_clanhome;"
        io << clan_id
        io << "\"> &amp;$802; </a></td></tr></table><table border=0 cellspacing=0 cellpadding=0 width=610 bgcolor=434343><tr><td height=10></td></tr><tr><td fixWIDTH=5></td><td fixwidth=600><a action=\"bypass _bbsclan_clanhome;"
        io << ";announce\">[CLAN ANNOUNCEMENT]</a> <a action=\"bypass _bbsclan_clanhome;"
        io << clan_id
        io << ";cbb\">[CLAN BULLETIN BOARD]</a><a action=\"bypass _bbsclan_clanhome;"
        io << clan_id
        io << ";cmail\">[CLAN MAIL]</a>&nbsp;&nbsp;<a action=\"bypass _bbsclan_clannotice_edit;"
        io << clan_id
        io << ";cnotice\">[CLAN NOTICE]</a>&nbsp;&nbsp;</td><td fixWIDTH=5></td></tr><tr><td height=10></td></tr></table><table border=0 cellspacing=0 cellpadding=0 width=610><tr><td height=10></td></tr><tr><td fixWIDTH=5></td><td fixwidth=290 valign=top></td><td fixWIDTH=5></td><td fixWIDTH=5 align=center valign=top><img src=\"l2ui.squaregray\" width=2  height=128></td><td fixWIDTH=5></td><td fixwidth=295><table border=0 cellspacing=0 cellpadding=0 width=295><tr><td fixWIDTH=100 align=left>CLAN NAME</td><td fixWIDTH=195 align=left>"
        io << clan.name
        io << "</td></tr><tr><td height=7></td></tr><tr><td fixWIDTH=100 align=left>CLAN LEVEL</td><td fixWIDTH=195 align=left height=16>"
        io << clan.level
        io << "</td></tr><tr><td height=7></td></tr><tr><td fixWIDTH=100 align=left>CLAN MEMBERS</td><td fixWIDTH=195 align=left height=16>"
        io << clan.size
        io << "</td></tr><tr><td height=7></td></tr><tr><td fixWIDTH=100 align=left>CLAN LEADER</td><td fixWIDTH=195 align=left height=16>"
        io << clan.leader_name
        io << "</td></tr><tr><td height=7></td></tr>"
        io << "<tr><td height=7></td></tr><tr><td fixWIDTH=100 align=left>ALLIANCE</td><td fixWIDTH=195 align=left height=16>"
        io << clan.ally_name
        io << "</td></tr></table></td><td fixWIDTH=5></td></tr><tr><td height=10></td></tr></table>"
        io << "<img src=\"L2UI.squareblank\" width=\"1\" height=\"5\"><img src=\"L2UI.squaregray\" width=\"610\" height=\"1\"><br></center><br> <br></body></html>"
      end
      CommunityBoardHandler.separate_and_send(html, pc)
    end
  end

  def write_community_board_command(pc : L2PcInstance, arg1 : String, arg2 : String, arg3 : String, arg4 : String, arg5 : String) : Bool
    clan = pc.clan

    if clan && pc.clan_leader?
      clan.notice = arg3
    end

    true
  end

  def commands
    {"_bbsclan", "_bbsclan_list", "_bbsclan_clanhome"}
  end
end
