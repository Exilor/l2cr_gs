module CommunityBoardHandler::FavoriteBoard
  extend self
  extend IParseBoardHandler

  private SELECT_FAVORITES = "SELECT * FROM `bbs_favorites` WHERE `playerId`=? ORDER BY `favAddDate` DESC"
  private DELETE_FAVORITE = "DELETE FROM `bbs_favorites` WHERE `playerId`=? AND `favId`=?"
  private ADD_FAVORITE = "REPLACE INTO `bbs_favorites`(`playerId`, `favTitle`, `favBypass`) VALUES(?, ?, ?)"

  def parse_command(command, pc)
    if command.starts_with?("_bbsgetfav")
      list = HtmCache.get_htm(pc, "data/html/CommunityBoard/favorite_list.html").not_nil!
      sb = String::Builder.new
      begin
        GameDB.each(SELECT_FAVORITES, pc.l2id) do |rs|
          link = list.gsub("%fav_bypass%", rs.get_string("favBypass"))
          link = link.gsub("%fav_title%", rs.get_string("favTitle"))
          link = link.gsub("%fav_add_date%", rs.get_time("favAddDate").to_s("%Y.%m.%d %H:%M:%S"))
          link = link.gsub("%fav_id%", rs.get_i32("favId"))
          sb << link
        end
        html = HtmCache.get_htm(pc, "data/html/CommunityBoard/favorite.html").not_nil!
        html = html.gsub("%fav_list%", sb.to_s)
        CommunityBoardHandler.separate_and_send(html, pc)
      rescue e
        error e
      end
    elsif command.starts_with?("bbs_add_fav")
      if bypass = CommunityBoardHandler.remove_bypass(pc)
        parts = bypass.split('&', 2)
        unless parts.size == 2
          warn { "Couldn't add favorite link (#{bypass} is not a valid bypass)." }
          return false
        end

        begin
          GameDB.exec(ADD_FAVORITE, pc.l2id, parts[0].strip, parts[1].strip)
          parse_command("_bbsgetfav", pc)
        rescue e
          error e
        end
      end
    elsif command.starts_with?("_bbsdelfav_")
      fav_id = command.gsub("_bbsdelfav_", "")
      unless fav_id.num?
        warn { "Couldn't delete favorite link (#{fav_id} is not a valid id)." }
        return false
      end

      begin
        GameDB.exec(DELETE_FAVORITE, pc.l2id, fav_id.to_i)
        parse_command("_bbsgetfav", pc)
      rescue e
        error e
      end
    end

    true
  end

  def commands
    {"_bbsgetfav", "bbs_add_fav", "_bbsdelfav_"}
  end
end
