require "./base_bbs_manager"

module TopicBBSManager
  extend self
  extend BaseBBSManager

  private TABLE = Concurrent::Array(Topic).new
  private MAX_ID = {} of Forum => Int32

  def add_topic(t : Topic)
    TABLE << t
  end

  def del_topic(t : Topic)
    TABLE.delete_first(t)
  end

  def set_max_id(id : Int32, f : Forum)
    MAX_ID[f] = id
  end

  def get_max_id(f : Forum) : Int32
    MAX_ID.fetch(f, 0)
  end

  def get_topic_by_id(id : Int32) : Topic?
    TABLE.find { |t| t.id == id }
  end

  def parse_write(a1 : String, a2 : String, a3 : String, a4 : String, a6 : String, pc : L2PcInstance)
    if a1 == "crea"
      f = ForumsBBSManager.get_forum_by_id(a2.to_i)
      if f.nil?
        CommunityBoardHandler.separate_and_send("<html><body><br><br><center>the forum: #{a2} is not implemented yet</center><br><br></body></html>", pc)
      else
        f.vload
        t = Topic.new(
          Topic::ConstructorType::CREATE,
          get_max_id(f) + 1,
          a2.to_i,
          a5,
          Time.ms,
          pc.name,
          pc.l2id,
          Topic::MEMO,
          0
        )
        f.add_topic(t)
        set_max_id(t.id, f)
        p = Post.new(pc.name, pc.l2id, Time.ms, t.id, f.id, a4)
        PostBBSManager.add_post_by_topic(p, t)
        parse_cmd("_bbsmemo", pc)
      end
    elsif a1 == "del"
      f = ForumsBBSManager.get_forum_by_id(a2.to_i)
      if f.nil?
        CommunityBoardHandler.separate_and_send("<html><body><br><br><center>the forum: #{a2} does not exist !</center><br><br></body></html>", pc)
      else
        t = f.get_topic(a3.to_i)
        if t.nil?
          CommunityBoardHandler.separate_and_send("<html><body><br><br><center>the topic: #{a3} does not exist !</center><br><br></body></html>", pc)
        else
          if p = PostBBSManager.get_g_post_by_topic(t)
            p.delete_me(t)
          end
          t.delete_me(f)
          parse_cmd("_bbsmemo", pc)
        end
      end
    else
      CommunityBoardHandler.separate_and_send("<html><body><br><br><center>the command: #{a1} is not implemented yet</center><br><br></body></html>", pc)
    end
  end

  def parse_cmd(command : String, pc : L2PcInstance)
    if command == "_bbsmemo"
      show_topics(pc.memo, pc, 1, pc.memo.id)
    elsif command.starts_with?("_bbstopics;read")
      st = command.split(';')
      st.shift
      st.shift
      id = st.shift.to_i
      ind = st.shift?.try &.to_i || 1
      show_topics(ForumsBBSManager.get_forum_by_id(id), pc, ind, id)
    elsif command.starts_with?("_bbstopics;crea")
      st = command.split(';')
      id = st[2].to_i
      show_new_topic(ForumsBBSManager.get_forum_by_id(id), pc, id)
    elsif command.starts_with?("_bbstopics;del")
      st = command.split(';')
      idf = st[2].to_i
      idt = st[3].to_i
      f =ForumsBBSManager.get_forum_by_id(idf)

      if f.nil?
        CommunityBoardHandler.separate_and_send("<html><body><br><br><center>the forum: #{idf} does not exist !</center><br><br></body></html>", pc)
      else
        t = f.get_topic(idt)
        if t.nil?
          CommunityBoardHandler.separate_and_send("<html><body><br><br><center>the topic: #{idt} does not exist !</center><br><br></body></html>", pc)
        else
          if p = PostBBSManager.get_g_post_by_topic(t)
            p.delete_me
          end
          t.delete_me(f)
          parse_cmd("_bbsmemo", pc)
        end
      end
    else
      CommunityBoardHandler.separate_and_send("<html><body><br><br><center>the command: #{command} is not implemented yet</center><br><br></body></html>", pc)
    end
  end

  private def show_new_topic(forum : Forum?, pc : L2PcInstance, idf : Int32)
    if forum.nil?
      CommunityBoardHandler.separate_and_send("<html><body><br><br><center>the forum: #{idf} is not implemented yet</center><br><br></body></html>", pc);
    elsif forum.type == Forum::MEMO
      show_memo_new_topics(forum, pc)
    else
      CommunityBoardHandler.separate_and_send("<html><body><br><br><center>the forum: #{forum.name} is not implemented yet</center><br><br></body></html>", pc);
    end
  end

  private def show_memo_new_topics(forum : Forum, pc : L2PcInstance)
    html = "<html><body><br><br><table border=0 width=610><tr><td width=10>" \
    "</td><td width=600 align=left><a action=\"bypass _bbshome\">HOME</a>&nbs" \
    "p;>&nbsp;<a action=\"bypass _bbsmemo\">Memo Form</a></td></tr></table>" \
    "<img src=\"L2UI.squareblank\" width=\"1\" height=\"10\"><center><table " \
    "border=0 cellspacing=0 cellpadding=0><tr><td width=610><img src=\"sek.c" \
    "bui355\" width=\"610\" height=\"1\"><br1><img src=\"sek.cbui355\" width" \
    "=\"610\" height=\"1\"></td></tr></table><table fixwidth=610 border=0 ce" \
    "llspacing=0 cellpadding=0><tr><td><img src=\"l2ui.mini_logo\" width=5 h" \
    "eight=20></td></tr><tr><td><img src=\"l2ui.mini_logo\" width=5 height=1" \
    "></td><td align=center FIXWIDTH=60 height=29>&$413;</td><td FIXWIDTH=54" \
    "0><edit var = \"Title\" width=540 height=13></td><td><img src=\"l2ui.mi" \
    "ni_logo\" width=5 height=1></td></tr></table><table fixwidth=610 border" \
    "=0 cellspacing=0 cellpadding=0><tr><td><img src=\"l2ui.mini_logo\" widt" \
    "h=5 height=10></td></tr><tr><td><img src=\"l2ui.mini_logo\" width=5 hei" \
    "ght=1></td><td align=center FIXWIDTH=60 height=29 valign=top>&$427;</td" \
    "><td align=center FIXWIDTH=540><MultiEdit var =\"Content\" width=535 he" \
    "ight=313></td><td><img src=\"l2ui.mini_logo\" width=5 height=1></td></t" \
    "r><tr><td><img src=\"l2ui.mini_logo\" width=5 height=10></td></tr></tab" \
    "le><table fixwidth=610 border=0 cellspacing=0 cellpadding=0><tr><td><im" \
    "g src=\"l2ui.mini_logo\" width=5 height=10></td></tr><tr><td><img " \
    "src=\"l2ui.mini_logo\" width=5 height=1></td><td align=center FIXWIDTH=" \
    "60 height=29>&nbsp;</td><td align=center FIXWIDTH=70><button value=\"&$" \
    "140;\" action=\"Write Topic crea #{forum.id} Ti" \
    "tle Content Title\" back=\"l2ui_ch3.smallbutton2_down\" width=65 height" \
    "=20 fore=\"l2ui_ch3.smallbutton2\" ></td><td align=center FIXWIDTH=70><" \
    "button value = \"&$141;\" action=\"bypass _bbsmemo\" back=\"l2ui_ch3.sm" \
    "allbutton2_down\" width=65 height=20 fore=\"l2ui_ch3.smallbutton2\"> </" \
    "td><td align=center FIXWIDTH=400>&nbsp;</td><td><img src=\"l2ui.mini_lo" \
    "go\" width=5 height=1></td></tr></table></center></body></html>"

    send_1001(html, pc)
    send_1002(pc)
  end

  private def show_topics(forum : Forum?, pc : L2PcInstance, index : Int32, idf : Int32)
    if forum.nil?
      CommunityBoardHandler.separate_and_send("<html><body><br><br><center>the forum: #{idf} is not implemented yet</center><br><br></body></html>", pc)
    elsif forum.type == Forum::MEMO
      show_memo_topics(forum, pc, index)
    else
      CommunityBoardHandler.separate_and_send("<html><body><br><br><center>the forum: #{forum.name} is not implemented yet</center><br><br></body></html>", pc)
    end
  end

  private def show_memo_topics(forum : Forum, pc : L2PcInstance, index : Int32)
    forum.vload
    html = String.build(2000) do |io|
      io << "<html><body><br><br><table border=0 width=610><tr><td width=10>" \
      "</td><td width=600 align=left><a action=\"bypass _bbshome\">HOME</a>&" \
      "nbsp;>&nbsp;<a action=\"bypass _bbsmemo\">Memo Form</a></td></tr></ta" \
      "ble><img src=\"L2UI.squareblank\" width=\"1\" height=\"10\"><center><" \
      "table border=0 cellspacing=0 cellpadding=2 bgcolor=888888 width=610><" \
      "tr><td FIXWIDTH=5></td><td FIXWIDTH=415 align=center>&$413;</td><td F" \
      "IXWIDTH=120 align=center></td><td FIXWIDTH=70 align=center>&$418;</td" \
      "></tr></table>"

      i = 0
      j = get_max_id(forum) + 1
      while i < (12 * index)
        if j < 0
          break
        end

        if t = forum.get_topic(j)
          if i >= 12 * (index - 1)
            io << "<table border=0 cellspacing=0 cellpadding=5 WIDTH=610><tr>" \
            "<td FIXWIDTH=5></td><td FIXWIDTH=415><a action=\"bypass _bbspost" \
            "s;read;"
            io << forum.id
            io << ';'
            io << t.id
            io << "\">"
            io << t.name
            io << "</a></td><td FIXWIDTH=120 align=center></td><td FIXWIDTH=70 align=center>"
            io << Time.now
            io << "</td></tr></table><img src=\"L2UI.Squaregray\" width=\"610\" height=\"1\">"
          end
          i &+= 1
        end

        j &-= 1
      end

      io << "<br><table width=610 cellspace=0 cellpadding=0><tr><td width=50>" \
      "<button value=\"&$422;\" action=\"bypass _bbsmemo\" back=\"l2ui_ch3.sm" \
      "allbutton2_down\" width=65 height=20 fore=\"l2ui_ch3.smallbutton2\"></" \
      "td><td width=510 align=center><table border=0><tr>"

      if index == 1
        io << "<td><button action=\"\" back=\"l2ui_ch3.prev1_down\" fore=\"l2" \
        "ui_ch3.prev1\" width=16 height=16 ></td>"
      else
        io << "<td><button action=\"bypass _bbstopics;read;"
        io << forum.id
        io << ';'
        io << (index - 1)
        io << "\" back=\"l2ui_ch3.prev1_down\" fore=\"l2ui_ch3.prev1\" width=16 height=16 ></td>"
      end

      nbp = forum.topic_size * 8
      if nbp * 8 != ClanTable.clan_count
        nbp += 1
      end

      1.upto(nbp) do |i|
        if i == index
          io << "<td> " << i << " </td>"
        else
          io << "<td><a action=\"bypass _bbstopics;read;"
          io << forum.id
          io << ';'
          io << i
          io << "\"> "
          io << i
          io << " </a></td>"
        end
      end

      if index == nbp
        io << "<td><button action=\"\" back=\"l2ui_ch3.next1_down\" fore=\"l2ui_ch3.next1\" width=16 height=16 ></td>"
      else
        io << "<td><button action=\"bypass _bbstopics;read;"
        io << forum.id
        io << ';'
        io << (index &+ 1)
        io << "\" back=\"l2ui_ch3.next1_down\" fore=\"l2ui_ch3.next1\" width=16 height=16 ></td>"
      end
    end

    io << "</tr></table> </td> <td align=right><button value = \"&$421;\" action=\"bypass _bbstopics;crea;"
    io << forum.id
    io << "\" back=\"l2ui_ch3.smallbutton2_down\" width=65 height=20 fore" \
    "=\"l2ui_ch3.smallbutton2\" ></td></tr><tr><td><img src=\"l2ui.mini_l" \
    "ogo\" width=5 height=10></td></tr><tr> <td></td><td align=center><ta" \
    "ble border=0><tr><td></td><td><edit var = \"Search\" width=130 heigh" \
    "t=11></td><td><button value=\"&$420;\" action=\"Write 5 -2 0 Search " \
    "_ _\" back=\"l2ui_ch3.smallbutton2_down\" width=65 height=20 fore=\"" \
    "l2ui_ch3.smallbutton2\"> </td> </tr></table> </td></tr></table><br><" \
    "br><br></center></body></html>"

    CommunityBoardHandler.separate_and_send(html, pc)
  end
end
