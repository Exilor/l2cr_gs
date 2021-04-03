require "./base_bbs_manager"

module PostBBSManager
  extend self
  extend BaseBBSManager

  private POSTS_BY_TOPIC = Concurrent::Map(Topic, Array(Post)).new

  def get_g_post_by_topic(t : Topic) : Array(Post)
    unless posts = POSTS_BY_TOPIC[t]?
      posts = GameDB.post.load(t)
      POSTS_BY_TOPIC[t] = posts
    end

    posts
  end

  def del_post_by_topic(t : Topic)
    POSTS_BY_TOPIC.delete(t)
  end

  def add_post_by_topic(topic : Topic, posts : Array(Post))
    POSTS_BY_TOPIC.store_if_absent(topic, posts)
  end

  def parse_cmd(command : String, pc : L2PcInstance)
    if command.starts_with?("_bbsposts;read;")
      st = command.split(';')
      idf = st[2].to_i
      idp = st[3].to_i
      index = st.shift?.try &.to_i || 1
      show_post(
        TopicBBSManager.get_topic_by_id(idp),
        ForumsBBSManager.get_forum_by_id(idf),
        pc,
        index
      )
    elsif command.starts_with?("_bbsposts;edit;")
      st = command.split(';')
      idf = st[2].to_i
      idt = st[3].to_i
      idp = st[4].to_i
      show_edit_post(
        TopicBBSManager.get_topic_by_id(idt),
        ForumsBBSManager.get_forum_by_id(idf),
        pc,
        idp
      )
    else
      CommunityBoardHandler.separate_and_send("<html><body><br><br><center>the command: #{command} is not implemented yet</center><br><br></body></html>", pc)
    end
  end

  private def show_edit_post(topic : Topic?, forum : Forum?, pc : L2PcInstance, idp : Int32)
    if topic.nil?
      CommunityBoardHandler.separate_and_send("<html><body><br><br><center>Error: This topic does not exist!</center></body></html>", pc)
    else
      p = get_g_post_by_topic(topic)
      if forum.nil? || p.nil?
        CommunityBoardHandler.separate_and_send("<html><body><br><br><center>Error: This forum or post does not exist!</center></body></html>", pc)
      else
        show_html_edit_post(topic, pc, forum, p)
      end
    end
  end

  private def show_post(topic : Topic?, forum : Forum?, pc : L2PcInstance, ind : Int32)
    if forum.nil? || topic.nil?
      CommunityBoardHandler.separate_and_send("<html><body><br><br><center>Error: This forum is not implemented yet!</center></body></html>", pc)
    elsif forum.type.memo?
      show_memo_post(topic, pc, forum)
    else
      CommunityBoardHandler.separate_and_send("<html><body><br><br><center>The forum: #{forum.name} is not implemented yet!</center></body></html>", pc)
    end
  end

  private def show_html_edit_post(topic : Topic, pc : L2PcInstance, forum : Forum, p : Post)
    html = String.build do |io|
      io << "<html><body><br><br><table border=0 width=610><tr><td width=10>" \
      "</td><td width=600 align=left><a action=\"bypass _bbshome\">HOME</a>&" \
      "nbsp;>&nbsp;<a action=\"bypass _bbsmemo\">"
      io << forum.name
      io << " Form</a></td></tr></table><img src=\"L2UI.squareblank\" width=" \
      "\"1\" height=\"10\"><center><table border=0 cellspacing=0 cellpadding" \
      "=0><tr><td width=610><img src=\"sek.cbui355\" width=\"610\" height=\"" \
      "1\"><br1><img src=\"sek.cbui355\" width=\"610\" height=\"1\"></td></t" \
      "r></table><table fixwidth=610 border=0 cellspacing=0 cellpadding=0><t" \
      "r><td><img src=\"l2ui.mini_logo\" width=5 height=20></td></tr><tr><td" \
      "><img src=\"l2ui.mini_logo\" width=5 height=1></td><td align=center F" \
      "IXWIDTH=60 height=29>&$413;</td><td FIXWIDTH=540>"
      io << topic.name
      io << "</td><td><img src=\"l2ui.mini_logo\" width=5 height=1></td></tr" \
      "></table><table fixwidth=610 border=0 cellspacing=0 cellpadding=0><tr" \
      "><td><img src=\"l2ui.mini_logo\" width=5 height=10></td></tr><tr><td>" \
      "<img src=\"l2ui.mini_logo\" width=5 height=1></td><td align=center FI" \
      "XWIDTH=60 height=29 valign=top>&$427;</td><td align=center FIXWIDTH=5" \
      "40><MultiEdit var =\"Content\" width=535 height=313></td><td><img src" \
      "=\"l2ui.mini_logo\" width=5 height=1></td></tr><tr><td><img src=\"l2u" \
      "i.mini_logo\" width=5 height=10></td></tr></table><table fixwidth=610" \
      " border=0 cellspacing=0 cellpadding=0><tr><td><img src=\"l2ui.mini_lo" \
      "go\" width=5 height=10></td></tr><tr><td><img src=\"l2ui.mini_logo\" " \
      "width=5 height=1></td><td align=center FIXWIDTH=60 height=29>&nbsp;</" \
      "td><td align=center FIXWIDTH=70><button value=\"&$140;\" action=\"Wri" \
      "te Post "
      io << forum.id
      io << ';'
      io << topic.id
      io << ";0 _ Content Content Content\" back=\"l2ui_ch3.smallbutton2_dow" \
      "n\" width=65 height=20 fore=\"l2ui_ch3.smallbutton2\" ></td><td align" \
      "=center FIXWIDTH=70><button value = \"&$141;\" action=\"bypass _bbsme" \
      "mo\" back=\"l2ui_ch3.smallbutton2_down\" width=65 height=20 fore=\"l2" \
      "ui_ch3.smallbutton2\"> </td><td align=center FIXWIDTH=400>&nbsp;</td>" \
      "<td><img src=\"l2ui.mini_logo\" width=5 height=1></td></tr></table></" \
      "center></body></html>"
    end

    send_1001(html, pc)
    send_1002(
      pc,
      p.get_c_post(0).text,
      topic.name,
      Time.from_ms(topic.date).to_s
    )
  end

  private def show_memo_post(topic : Topic, pc : L2PcInstance, forum : Forum)
    p = get_g_post_by_topic(topic)
    mes = p.get_c_post(0).text.gsub(">", "&gt;")
    mes = mes.gsub("<", "&lt;")

    html = String.build do |io|
      io << "<html><body><br><br><table border=0 width=610><tr><td width=10></td><td width=600 align=left><a action=\"bypass _bbshome\">HOME</a>&nbsp;>&nbsp;<a action=\"bypass _bbsmemo\">Memo Form</a></td></tr></table><img src=\"L2UI.squareblank\" width=\"1\" height=\"10\"><center><table border=0 cellspacing=0 cellpadding=0 bgcolor=333333><tr><td height=10></td></tr><tr><td fixWIDTH=55 align=right valign=top>&$413; : &nbsp;</td><td fixWIDTH=380 valign=top>"
      io << topic.name
      io << "</td><td fixwidth=5></td><td fixwidth=50></td><td fixWIDTH=120></td></tr><tr><td height=10></td></tr><tr><td align=right><font color=\"AAAAAA\" >&$417; : &nbsp;</font></td><td><font color=\"AAAAAA\">"
      io << topic.owner_name
      io << "</font></td><td></td><td><font color=\"AAAAAA\">&$418; :</font></td><td><font color=\"AAAAAA\">"
      io << Time.from_ms(p.get_c_post(0).post_date)
      io << "</font></td></tr><tr><td height=10></td></tr></table><br><table border=0 cellspacing=0 cellpadding=0><tr><td fixwidth=5></td><td FIXWIDTH=600 align=left>"
      io << mes
      io << "</td><td fixqqwidth=5></td></tr></table><br><img src=\"L2UI.squareblank\" width=\"1\" height=\"5\"><img src=\"L2UI.squaregray\" width=\"610\" height=\"1\"><img src=\"L2UI.squareblank\" width=\"1\" height=\"5\"><table border=0 cellspacing=0 cellpadding=0 FIXWIDTH=610><tr><td width=50><button value=\"&$422;\" action=\"bypass _bbsmemo\" back=\"l2ui_ch3.smallbutton2_down\" width=65 height=20 fore=\"l2ui_ch3.smallbutton2\"></td><td width=560 align=right><table border=0 cellspacing=0><tr><td FIXWIDTH=300></td><td><button value = \"&$424;\" action=\"bypass _bbsposts;edit;"
      io << forum.id
      io << ';'
      io << topic.id
      io << ";0\" back=\"l2ui_ch3.smallbutton2_down\" width=65 height=20 fore=\"l2ui_ch3.smallbutton2\" ></td>&nbsp;<td><button value = \"&$425;\" action=\"bypass _bbstopics;del;"
      io << forum.id
      io << ';'
      io << topic.id
      io << "\" back=\"l2ui_ch3.smallbutton2_down\" width=65 height=20 fore=\"l2ui_ch3.smallbutton2\" ></td>&nbsp;<td><button value = \"&$421;\" action=\"bypass _bbstopics;crea;"
      io << forum.id
      io << "\" back=\"l2ui_ch3.smallbutton2_down\" width=65 height=20 fore=\"l2ui_ch3.smallbutton2\" ></td>&nbsp;</tr></table></td></tr></table><br><br><br></center></body></html>"
    end

    CommunityBoardHandler.separate_and_send(html, pc)
  end

  def parse_write(a1 : String, a2 : String, a3 : String, a4 : String, a5 : String, pc : L2PcInstance)
    st = a1.split(';')
    idf = st[0].to_i
    idt = st[1].to_i
    idp = st[2].to_i

    f = ForumsBBSManager.get_forum_by_id(idf)
    if f.nil?
      CommunityBoardHandler.separate_and_send("<html><body><br><br><center>the forum: #{idf} does not exist !</center><br><br></body></html>", pc)
    else
      t = f.get_topic(idt)
      if t.nil?
        CommunityBoardHandler.separate_and_send("<html><body><br><br><center>the topic: #{idt} does not exist !</center><br><br></body></html>", pc)
      else
        p = get_g_post_by_topic(t)
        unless p.empty?
          cp = p[idp]?
          if cp.nil?
            CommunityBoardHandler.separate_and_send("<html><body><br><br><center>the post: #{idp} does not exist !</center><br><br></body></html>", pc)
          else
            p.get_c_post(idp).text = a4
            GameDB.post.update(p)
            parse_cmd("_bbsposts;read;#{f.id};#{t.id}", pc)
          end
        end
      end
    end
  end
end
