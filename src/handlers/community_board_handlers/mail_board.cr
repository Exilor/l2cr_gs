module CommunityBoardHandler::MailBoard
  extend self
  extend IParseBoardHandler

  def parse_command(command : String, pc : L2PcInstance) : Bool
    CommunityBoardHandler.add_bypass(pc, "Mail Command", command)

    html = HtmCache.get_htm(pc, "data/html/CommunityBoard/mail.html")
    CommunityBoardHandler.separate_and_send(html.not_nil!, pc)
    true
  end

  def write_community_board_command(pc : L2PcInstance, arg1 : String, arg2 : String, arg3 : String, arg4 : String, arg5 : String) : Bool
    false # L2J TODO
  end

  def commands : Enumerable(String)
    {"_maillist"}
  end
end
