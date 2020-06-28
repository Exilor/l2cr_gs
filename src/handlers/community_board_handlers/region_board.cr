module CommunityBoardHandler::RegionBoard
  extend self
  extend IParseBoardHandler

  private REGIONS = {1049, 1052, 1053, 1057, 1060, 1059, 1248, 1247, 1056}

  def parse_command(command, pc)
    if command == "_bbsloc"
      CommunityBoardHandler.add_bypass(pc, "Region", command)

      list = HtmCache.get_htm_force(pc, "data/html/CommunityBoard/region_list.html")
      str = String.build(50) do |io|
        CastleManager.castles.each_with_index do |castle, i|
          clan = ClanTable.get_clan(castle.owner_id)
          link = list.gsub("%region_id%", i.to_s)
          link = link.sub("%region_name%", REGIONS[i].to_s)
          link = link.sub("%region_owning_clan%", clan.try &.name || "NPC")
          link = link.sub("%region_owning_clan_alliance%", clan.try &.ally_name || "")
          link = link.sub("%region_tax_rate%", "#{castle.tax_rate * 100}%")
          io << link
        end
      end

      html = HtmCache.get_htm_force(pc, "data/html/CommunityBoard/region.html")
      html = html.sub("%region_list%", str)
      CommunityBoardHandler.separate_and_send(html, pc)
    elsif command.starts_with?("_bbsloc;")
      CommunityBoardHandler.add_bypass(pc, "Region>", command)
      id = command.sub("_bbsloc;", "")
      unless id.number?
        warn { "Player #{pc.name} sent an invalid region bypass: '#{command}'." }
        return false
      end

      # L2J TODO
    end

    true
  end

  def write_community_board_command(pc : L2PcInstance, arg1 : String, arg2 : String, arg3 : String, arg4 : String, arg5 : String) : Bool
    false # L2J TODO
  end

  def commands
    {"_bbsloc"}
  end
end
