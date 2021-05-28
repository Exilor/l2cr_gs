module AdminCommandHandler::AdminAnnouncements
  extend self
  extend AdminCommandHandler

  def use_admin_command(command : String, pc : L2PcInstance) : Bool
    st = command.split
    cmd = st.empty? ? "" : st.shift
    case cmd
    when "admin_announce", "admin_announce_crit", "admin_announce_screen"
      if st.empty?
        pc.send_message("Syntax: #announce <text to announce here>")
        return false
      end
      announce = st.shift
      until st.empty?
        announce += " " + st.shift
      end
      if cmd == "admin_announce_screen"
        Broadcast.to_all_online_players_on_screen(announce)
      else
        if Config.gm_announcer_name
          announce = "#{announce} [#{pc}]"
        end
        Broadcast.to_all_online_players(announce, cmd == "admin_announce_crit")
      end
      AdminHtml.show_admin_html(pc, "gm_menu.htm")
    when "admin_announces"
      sub_cmd = st.empty? ? "" : st.shift
      case sub_cmd
      when "add"
        if st.empty?
          content = HtmCache.get_htm(pc, "data/html/admin/announces-add.htm")
          Util.send_cb_html(pc, content.not_nil!)
          return false
        end
        ann_type = st.shift
        type = AnnouncementType.parse(ann_type)
        # ************************************
        if st.empty?
          pc.send_message("Syntax: #announces add <type> <delay> <repeat> <text>")
          return false
        end
        ann_init_delay = st.shift
        unless ann_init_delay.number?
          pc.send_message("Syntax: #announces add <type> <delay> <repeat> <text>")
          return false
        end
        init_delay = ann_init_delay.to_i * 1000
        # ************************************
        if st.empty?
          pc.send_message("Syntax: #announces add <type> <delay> <repeat> <text>")
          return false
        end
        ann_delay = st.shift
        unless ann_delay.number?
          pc.send_message("Syntax: #announces add <type> <delay> <repeat> <text>")
          return false
        end
        delay = ann_delay.to_i * 1000
        if delay < 10 &* 1000 && (type.auto_normal? || type.auto_critical?)
          pc.send_message("Delay cannot be less then 10 seconds")
          return false
        end
        # ************************************
        if st.empty?
          pc.send_message("Syntax: #announces add <type> <delay> <repeat> <text>")
          return false
        end
        ann_repeat = st.shift
        unless ann_repeat.number?
          pc.send_message("Syntax: #announces add <type> <delay> <repeat> <text>")
          return false
        end
        repeat = ann_repeat.to_i
        if repeat == 0
          repeat = -1
        end
        # ************************************
        if st.empty?
          pc.send_message("Syntax: #announces add <type> <delay> <repeat> <text>")
          return false
        end
        content = st.shift
        until st.empty?
          content += " " + st.shift
        end
        # ************************************
        if type.auto_critical? || type.auto_normal?
          announce = AutoAnnouncement.new(type, content, pc.name, init_delay.to_i64, delay.to_i64, repeat)
        else
          announce = Announcement.new(type, content, pc.name)
        end
        AnnouncementsTable.add_announcement(announce)
        pc.send_message("Announcement has been successfully added")
        return use_admin_command("admin_announces list", pc)
      when "edit"
        if st.empty?
          pc.send_message("Syntax: #announces edit <id>")
          return false
        end
        ann_id = st.shift
        unless ann_id.number?
          pc.send_message("Syntax: #announces edit <id>")
          return false
        end
        id = ann_id.to_i
        announce = AnnouncementsTable.get_announce(id)
        unless announce
          pc.send_message("Announcement doesn't exist")
          return false
        end
        if st.empty?
          content = HtmCache.get_htm(pc, "data/html/admin/announces-edit.htm").not_nil!
          announcement_id = announce.id.to_s
          announcement_type = announce.type.to_s
          announcement_inital = "0"
          announcement_delay = "0"
          announcement_repeat = "0"
          announcement_author = announce.author
          announcement_content = announce.content
          if aa = announce.as?(AutoAnnouncement)
            announcement_inital = (aa.initial // 1000).to_s
            announcement_delay = (aa.delay // 1000).to_s
            announcement_repeat = aa.repeat.to_s
          end
          content = content.gsub("%id%", announcement_id)
          content = content.gsub("%type%", announcement_type)
          content = content.gsub("%initial%", announcement_inital)
          content = content.gsub("%delay%", announcement_delay)
          content = content.gsub("%repeat%", announcement_repeat)
          content = content.gsub("%author%", announcement_author)
          content = content.gsub("%content%", announcement_content)
          Util.send_cb_html(pc, content)
          return false
        end
        ann_type = st.shift
        type = AnnouncementType.parse(ann_type)
        case announce.type
        when AnnouncementType::AUTO_CRITICAL, AnnouncementType::AUTO_NORMAL
          case type
          when AnnouncementType::AUTO_CRITICAL, AnnouncementType::AUTO_NORMAL
            # do nothing
          else
            pc.send_message("Announce type can be changed only to AUTO_NORMAL or AUTO_CRITICAL")
            return false
          end
        when AnnouncementType::NORMAL, AnnouncementType::CRITICAL
          case type
          when AnnouncementType::NORMAL, AnnouncementType::CRITICAL
            # do nothing
          else
            pc.send_message("Announce type can be changed only to NORMAL or CRITICAL")
            return false
          end
        end

        # ************************************
        if st.empty?
          pc.send_message("Syntax: #announces add <type> <delay> <repeat> <text>")
          return false
        end
        ann_init_delay = st.shift
        unless ann_init_delay.number?
          pc.send_message("Syntax: #announces add <type> <delay> <repeat> <text>")
          return false
        end
        init_delay = ann_init_delay.to_i
        # ************************************
        if st.empty?
          pc.send_message("Syntax: #announces add <type> <delay> <repeat> <text>")
          return false
        end
        ann_delay = st.shift
        unless ann_delay.number?
          pc.send_message("Syntax: #announces add <type> <delay> <repeat> <text>")
          return false
        end
        delay = ann_delay.to_i
        if delay < 10 && (type.auto_normal? || type.auto_critical?)
          pc.send_message("Delay cannot be less then 10 seconds")
          return false
        end
        # ************************************
        if st.empty?
          pc.send_message("Syntax: #announces add <type> <delay> <repeat> <text>")
          return false
        end
        ann_repeat = st.shift
        unless ann_repeat.number?
          pc.send_message("Syntax: #announces add <type> <delay> <repeat> <text>")
          return false
        end
        repeat = ann_repeat.to_i
        if repeat == 0
          repeat = -1
        end
        # ************************************
        content = ""
        unless st.empty?
          content = st.shift
          until st.empty?
            content += " " + st.shift
          end
        end
        if content.empty?
          content = announce.content
        end
        # ************************************
        announce.type = type
        announce.content = content
        announce.author = pc.name
        if aa = announce.as?(AutoAnnouncement)
          aa.initial = init_delay.to_i64 * 1000
          aa.delay = delay.to_i64 * 1000
          aa.repeat = repeat
        end
        announce.update_me
        pc.send_message("Announcement has been successfully edited")
        return use_admin_command("admin_announces list", pc)
      when "remove"
        if st.empty?
          pc.send_message("Syntax: #announces remove <announcement id>")
          return false
        end
        token = st.shift
        unless token.number?
          pc.send_message("Syntax: #announces remove <announcement id>")
          return false
        end
        id = token.to_i
        if AnnouncementsTable.delete_announcement(id)
          pc.send_message("Announcement has been successfully removed")
        else
          pc.send_message("Announcement doesn't exist")
        end
        return use_admin_command("admin_announces list", pc)
      when "restart"
        if st.empty?
          AnnouncementsTable.all_announcements.each do |announce|
            if announce.is_a?(AutoAnnouncement)
              announce.restart_me
            end
          end
          pc.send_message("Auto announcements has been successfully restarted")
          return false
        end
        token = st.shift
        unless token.number?
          pc.send_message("Syntax: #announces show <announcement id>")
          return false
        end
        id = token.to_i

        if announce = AnnouncementsTable.get_announce(id)
          if auto_announce = announce.as?(AutoAnnouncement)
            auto_announce.restart_me
            pc.send_message("Auto announcement has been successfully restarted")
          else
            pc.send_message("This option has effect only on auto announcements")
          end
        else
          pc.send_message("Announcement doesn't exist")
          return false
        end
      when "show"
        if st.empty?
          pc.send_message("Syntax: #announces show <announcement id>")
          return false
        end
        token = st.shift
        unless token.number?
          pc.send_message("Syntax: #announces show <announcement id>")
          return false
        end
        id = token.to_i

        if announce = AnnouncementsTable.get_announce(id)
          content = HtmCache.get_htm(pc, "data/html/admin/announces-show.htm").not_nil!
          announcement_id = announce.id.to_s
          announcement_type = announce.type.to_s
          announcement_inital = "0"
          announcement_delay = "0"
          announcement_repeat = "0"
          announcement_author = announce.author
          announcement_content = announce.content
          if aa = announce.as?(AutoAnnouncement)
            announcement_inital = (aa.initial // 1000).to_s
            announcement_delay = (aa.delay // 1000).to_s
            announcement_repeat = aa.repeat.to_s
          end
          content = content.gsub("%id%", announcement_id)
          content = content.gsub("%type%", announcement_type)
          content = content.gsub("%initial%", announcement_inital)
          content = content.gsub("%delay%", announcement_delay)
          content = content.gsub("%repeat%", announcement_repeat)
          content = content.gsub("%author%", announcement_author)
          content = content.gsub("%content%", announcement_content)
          Util.send_cb_html(pc, content)
          return false
        end
        pc.send_message("Announcement doesn't exist")
        return use_admin_command("admin_announces list", pc)
      when "list"
        page = 0
        unless st.empty?
          token = st.shift
          if token.number?
            page = token.to_i
          end
        end

        content = HtmCache.get_htm(pc, "data/html/admin/announces-list.htm").not_nil!
        pager_function = ->(current_page : Int32) do
          "<td align=center><button action=\"bypass admin_announces list #{current_page}\" value=\"#{current_page + 1}\" width=35 height=20 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>"
        end
        body_function = ->(announcement : IAnnouncement) do
          String.build do |io|
            io << "<tr>"
            io << "<td width=5></td>"
            io << "<td width=80>"
            io << announcement.id
            io << "</td>"
            io << "<td width=100>"
            io << announcement.type
            io << "</td>"
            io << "<td width=100>"
            io << announcement.author
            io << "</td>"
            if announcement.type.auto_normal? || announcement.type.auto_critical?
              io << "<td width=60><button action=\"bypass -h admin_announces restart "
              io << announcement.id
              io << "\" value=\"Restart\" width=\"60\" height=\"21\" back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>"
            else
              io << "<td width=60><button action=\"\" value=\"\" width=\"60\" height=\"21\" back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>"
            end
            if announcement.type.event?
              io << "<td width=60><button action=\"bypass -h admin_announces show "
              io << announcement.id
              io << "\" value=\"Show\" width=\"60\" height=\"21\" back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>"
              io << "<td width=60></td>"
            else
              io << "<td width=60><button action=\"bypass -h admin_announces show "
              io << announcement.id
              io << "\" value=\"Show\" width=\"60\" height=\"21\" back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>"
              io << "<td width=60><button action=\"bypass -h admin_announces edit "
              io << announcement.id
              io << "\" value=\"Edit\" width=\"60\" height=\"21\" back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>"
            end
            io << "<td width=60><button action=\"bypass -h admin_announces remove "
            io << announcement.id
            io << "\" value=\"Remove\" width=\"60\" height=\"21\" back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>"
            io << "<td width=5></td>"
            io << "</tr>"
          end
        end
        result = HtmlUtil.create_page(AnnouncementsTable.all_announcements, page, 8, pager_function, body_function)
        content = content.gsub("%pages%", result.pager_template.to_s)
        content = content.gsub("%announcements%", result.body_template.to_s)
        Util.send_cb_html(pc, content)
      end
    end

    false
  end

  def commands : Enumerable(String)
    {
      "admin_announce",
      "admin_announce_crit",
      "admin_announce_screen",
      "admin_announces",
    }
  end
end
