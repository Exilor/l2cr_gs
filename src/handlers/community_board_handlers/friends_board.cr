module CommunityBoardHandler::FriendsBoard
  extend self
  extend IParseBoardHandler

  def parse_command(command, pc)
    case command
    when "_friendlist"
      CommunityBoardHandler.add_bypass(pc, "Friends List", command)
      html = HtmCache.get_htm(pc, "data/html/CommunityBoard/friends_list.html").not_nil!
      CommunityBoardHandler.separate_and_send(html, pc)
    when "_friendblocklist"
      CommunityBoardHandler.add_bypass(pc, "Ignore list", command)
      html = HtmCache.get_htm(pc, "data/html/CommunityBoard/friends_block_list.html").not_nil!
      CommunityBoardHandler.separate_and_send(html, pc)
    else
      # [automatically added else]
    end


    true
  end

  def commands
    {"_friendlist", "_friendblocklist"}
  end
end
