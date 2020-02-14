module CommunityBoardHandler::HomepageBoard
  extend self
  extend IParseBoardHandler

  def parse_command(command, pc)
    html = HtmCache.get_htm(pc, "data/html/CommunityBoard/homepage.html")
    CommunityBoardHandler.separate_and_send(html.not_nil!, pc)
    true
  end

  def commands
    {"_bbslink"}
  end
end
