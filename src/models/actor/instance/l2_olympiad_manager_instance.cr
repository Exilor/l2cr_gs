class L2OlympiadManagerInstance < L2Npc
  def show_chat_window(pc : L2PcInstance, val : Int32, suffix : String?)
    if suffix && !suffix.empty?
      file_name = "#{Olympiad::OLYMPIAD_HTML_PATH}noble_desc#{val}#{suffix}.htm"
    else
      if val == 0
        file_name = Olympiad::OLYMPIAD_HTML_PATH + "noble_main.htm"
      else
        file_name = "#{Olympiad::OLYMPIAD_HTML_PATH}noble_desc#{val}.htm"
      end
    end

    show_chat_window(pc, file_name)
  end

  def instance_type : InstanceType
    InstanceType::L2OlympiadManagerInstance
  end
end
