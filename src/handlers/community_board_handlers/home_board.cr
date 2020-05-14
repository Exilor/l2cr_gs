module CommunityBoardHandler::HomeBoard
  extend self
  extend IParseBoardHandler

  private COUNT_FAVORITES = "SELECT COUNT(*) AS favorites FROM `bbs_favorites` WHERE `playerId`=?"

  def parse_command(command, pc)
    if commands.includes?(command)
      CommunityBoardHandler.add_bypass(pc, "Home", command)

      html = HtmCache.get_htm_force("data/html/CommunityBoard/home.html") # L2J: get_htm
      html = html.gsub("%fav_count%", get_favorite_count(pc).to_s)
      html = html.gsub("%region_count%", get_region_count(pc).to_s)
      html = html.gsub("%clan_count%", ClanTable.clan_count.to_s)
      CommunityBoardHandler.separate_and_send(html, pc)
    elsif command.starts_with?("_bbstop;")
      path = command.sub("_bbstop;", "")
      if path.size > 0 && path.ends_with?(".html")
        html = HtmCache.get_htm_force("data/html/CommunityBoard/#{path}") # L2J: get_htm
        CommunityBoardHandler.separate_and_send(html, pc)
      end
    end

    true
  end

  private def get_favorite_count(pc)
    begin
      GameDB.each(COUNT_FAVORITES, pc.l2id) do |rs|
        return rs.get_i32(:"favorites")
      end
    rescue e
      error e
    end

    0
  end

  private def get_region_count(pc)
    0 # L2J hasn't implemented it
  end

  def commands
    {"_bbshome", "_bbstop"}
  end
end
