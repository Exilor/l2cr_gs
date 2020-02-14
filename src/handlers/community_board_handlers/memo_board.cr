module CommunityBoardHandler::MemoBoard
  extend self
  extend IParseBoardHandler

  def parse_command(command, pc)
    CommunityBoardHandler.add_bypass(pc, "Memo Command", command)

    html = HtmCache.get_htm(pc, "data/html/CommunityBoard/memo.html")
    CommunityBoardHandler.separate_and_send(html.not_nil!, pc)
    true
  end

  def write_community_board_command(pc : L2PcInstance, arg1 : String, arg2 : String, arg3 : String, arg4 : String, arg5 : String) : Bool
    false # L2J TODO
  end

  def commands
    {"_bbsmemo", "_bbstopics"}
  end
end
