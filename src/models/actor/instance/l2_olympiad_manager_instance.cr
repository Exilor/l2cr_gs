class L2OlympiadManagerInstance < L2Npc
  def show_chat_window(pc : L2PcInstance, val : Int32, suffix : String?)
    file_name = Olympiad::OLYMPIAD_HTML_PATH
    file_name += "noble_desc#{val}"
    file_name += (suffix ? suffix + ".htm" : ".htm")
    if file_name == Olympiad::OLYMPIAD_HTML_PATH + "noble_desc0.htm"
      file_name = Olympiad::OLYMPIAD_HTML_PATH + "noble_main.htm"
    end

    show_chat_window(pc, file_name)
  end

  def instance_type : InstanceType
    InstanceType::L2OlympiadManagerInstance
  end
end
