module VoicedCommandHandler::Lang
  extend self
  extend VoicedCommandHandler

  private COMMANDS = {"lang"}

  def use_voiced_command(cmd : String, pc : L2PcInstance, params : String) : Bool
    if !Config.multilang_enable || !Config.multilang_voiced_allow
      return false
    end

    msg = NpcHtmlMessage.new
    if params.empty?
      html = String::Builder.new(100)
      Config.multilang_allowed.each do |lang|
        html << "<button value=\""
        html << lang.upcase
        html << "\" action=\"bypass -h voice .lang "
        html << lang
        html << "\" width=60 height=21 back=\"L2UI_ct1.button_df\" fore=\"L2UI_ct1.button_df\"><br>"
      end
      msg.set_file(pc, "data/html/mods/Lang/LanguageSelect.htm")
      msg["%list%"] = html
      pc.send_packet(msg)
      return true
    end

    st = params.split
    unless st.empty?
      lang = st.shift.strip
      if pc.set_lang(lang)
        msg.set_file(pc, "data/html/mods/Lang/Ok.htm")
        pc.send_packet(msg)
        return true
      end

      msg.set_file(pc, "data/html/mods/Lang/Error.htm")
      pc.send_packet(msg)
      return true
    end

    false
  end

  def commands : Indexable(String)
    COMMANDS
  end
end
