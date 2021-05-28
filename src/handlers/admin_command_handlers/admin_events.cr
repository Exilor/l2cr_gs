require "../../models/quests/event"

module AdminCommandHandler::AdminEvents
  extend self
  extend AdminCommandHandler

  def use_admin_command(command : String, pc : L2PcInstance) : Bool
    unless pc
      return false
    end

    event_name = ""
    event_bypass = ""
    st = command.split
    st.shift
    unless st.empty?
      event_name = st.shift
    end
    unless st.empty?
      event_bypass = st.shift
    end

    if command.includes?("_menu")
      show_menu(pc)
    end

    if command.starts_with?("admin_event_start")
      begin
        if event = QuestManager.get_quest(event_name).as?(Event)
          if event.event_start(pc)
            pc.send_message("Event #{event_name} started.")
            return true
          end

          pc.send_message("There is problem starting #{event_name} event.")
          return true
        end
      rescue e
        pc.send_message("Usage: #event_start <eventname>")
        error e
        return false
      end
    elsif command.starts_with?("admin_event_stop")
      begin
        if event = QuestManager.get_quest(event_name).as?(Event)
          if event.event_stop
            pc.send_message("Event #{event_name} stopped.")
            return true
          end

          pc.send_message("There is problem with stoping #{event_name} event.")
          return true
        end
      rescue e
        pc.send_message("Usage: #event_start <eventname>")
        error e
        return false
      end
    elsif command.starts_with?("admin_event_bypass")
      begin
        if event = QuestManager.get_quest(event_name).as?(Event)
          event.event_bypass(pc, event_bypass)
        end
      rescue e
        pc.send_message("Usage: #event_bypass <eventname> <bypass>")
        error e
        return false
      end
    end

    false
  end

  private def show_menu(pc)
    html = NpcHtmlMessage.new
    html.set_file(pc, "data/html/admin/gm_events.htm")
    list = String.build(500) do |io|
      QuestManager.scripts.each_value do |event|
        # Elpies, Race and Rabbits are the subclasses of Event.
        if event.is_a?(Event)
          io << "<font color=\"LEVEL\">"
          io << event.name
          io << ":</font><br1><table width=270><tr><td><button value=\"Start\" action=\"bypass -h admin_event_start_menu "
          io << event.name
          io << "\" width=80 height=21 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td><td><button value=\"Stop\" action=\"bypass -h admin_event_stop_menu "
          io << event.name
          io << "\" width=80 height=21 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td><td><button value=\"Menu\" action=\"bypass -h admin_event_bypass "
          io << event.name
          io << "\" width=80 height=21 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"></td></tr></table><br>"
        end
      end
    end
    html["%LIST%"] = list
    pc.send_packet(html)
  end

  def commands : Enumerable(String)
    {
      "admin_event_menu",
      "admin_event_start",
      "admin_event_stop",
      "admin_event_start_menu",
      "admin_event_stop_menu",
      "admin_event_bypass"
    }
  end
end
