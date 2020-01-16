class L2AuctioneerInstance < L2Npc
  private COND_ALL_FALSE = 0
  private COND_BUSY_BECAUSE_OF_SIEGE = 1
  private COND_REGULAR = 3

  @pending_auctions = Concurrent::Map(Int32, Auction).new

  def instance_type : InstanceType
    InstanceType::L2AuctioneerInstance
  end

  def on_bypass_feedback(pc : L2PcInstance, command : String)
    condition = validate_condition(pc)
    if condition <= COND_ALL_FALSE
      # (L2J) TODO: html
      pc.send_message("Wrong conditions.")
      return
    elsif condition == COND_BUSY_BECAUSE_OF_SIEGE
      filename = "data/html/auction/auction-busy.htm"
      html = NpcHtmlMessage.new(l2id)
      html.set_file(pc, filename)
      html["%objectId%"] = l2id
      pc.send_packet(html)
      return
    elsif condition == COND_REGULAR
      st = command.split
      actual_cmd = st.shift

      val = ""
      unless st.empty?
        val = st.shift
      end

      if actual_cmd.casecmp?("auction")
        if val.empty?
          return
        end

        begin
          days = val.to_i64
          begin
            format = "%d/%m/%Y %H:%M"
            bid = 0i64
            unless st.empty?
              bid = Math.min(st.shift.to_i64, Inventory.max_adena)
            end
            clan = pc.clan.not_nil!
            a = Auction.new(clan.hideout_id, clan, days * 86400000, bid, ClanHallManager.get_clan_hall_by_owner(clan).not_nil!.name)

            @pending_auctions[a.id] = a

            filename = "data/html/auction/AgitSale3.htm"
            html = NpcHtmlMessage.new(l2id)
            html.set_file(pc, filename)
            html["%x%"] = val
            html["%AGIT_AUCTION_END%"] = Time.from_ms(a.end_date).to_s(format)
            html["%AGIT_AUCTION_MINBID%"] = a.starting_bid
            html["%AGIT_AUCTION_MIN%"] = a.starting_bid
            html["%AGIT_AUCTION_DESC%"] = ClanHallManager.get_clan_hall_by_owner(clan).not_nil!.desc
            html["%AGIT_LINK_BACK%"] = "bypass -h npc_#{l2id}_sale2"
            html["%objectId%"] = l2id
            pc.send_packet(html)
          rescue
            pc.send_message("Invalid bid")
          end
        rescue
          pc.send_message("Invalid auction duration")
        end
        return
      elsif actual_cmd.casecmp?("confirmAuction")
        begin
          a = @pending_auctions[pc.clan.not_nil!.hideout_id]
          a.confirm_auction
          @pending_auctions.delete(pc.clan.not_nil!.hideout_id)
        rescue
          pc.send_message("Invalid auction")
        end
        return
      elsif actual_cmd.casecmp?("bidding")
        if val.empty?
          return
        end

        debug "bidding show successful"

        begin
          format = "%d/%m/%Y %H:%M"
          auction_id = val.to_i

          debug "auction test started"

          filename = "data/html/auction/AgitAuctionInfo.htm"

          html = NpcHtmlMessage.new(l2id)
          html.set_file(pc, filename)
          if a = AuctionManager.get_auction(auction_id)
            html["%AGIT_NAME%"] = a.item_name
            html["%OWNER_PLEDGE_NAME%"] = a.seller_clan_name
            html["%OWNER_PLEDGE_MASTER%"] = a.seller_name
            html["%AGIT_SIZE%"] = ClanHallManager.get_auctionable_hall_by_id(a.item_id).not_nil!.grade * 10
            html["%AGIT_LEASE%"] = ClanHallManager.get_auctionable_hall_by_id(a.item_id).not_nil!.lease
            html["%AGIT_LOCATION%"] = ClanHallManager.get_auctionable_hall_by_id(a.item_id).not_nil!.location
            html["%AGIT_AUCTION_END%"] = Time.from_ms(a.end_date).to_s(format)
            html["%AGIT_AUCTION_REMAIN%"] = "#{(a.end_date - Time.ms) // 3600000} hours #{((a.end_date - Time.ms) // 60000) % 60} minutes"
            html["%AGIT_AUCTION_MINBID%"] = a.starting_bid
            html["%AGIT_AUCTION_COUNT%"] = a.bidders.size
            html["%AGIT_AUCTION_DESC%"] = ClanHallManager.get_auctionable_hall_by_id(a.item_id).not_nil!.desc
            html["%AGIT_LINK_BACK%"] = "bypass -h npc_#{l2id}_list"
            html["%AGIT_LINK_BIDLIST%"] = "bypass -h npc_#{l2id}_bidlist #{a.id}"
            html["%AGIT_LINK_RE%"] = "bypass -h npc_#{l2id}_bid1 #{a.id}"
          else
            debug "Auctioneer Auction null for Auction_id: #{auction_id}"
          end

          pc.send_packet(html)
        rescue
          pc.send_message("Invalid auction")
        end
        return
      elsif actual_cmd.casecmp?("bid")
        if val.empty?
          return
        end

        begin
          auction_id = val.to_i
          begin
            bid = 0i64
            unless st.empty?
              bid = Math.min(st.shift.to_i64, Inventory.max_adena)
            end

            AuctionManager.get_auction(auction_id).not_nil!.set_bid(pc, bid)
          rescue
            pc.send_message("Invalid bid")
          end
        rescue
          pc.send_message("Invalid auction")
        end
        return
      elsif actual_cmd.casecmp?("bid1")
        clan = pc.clan
        if clan.nil? || clan.level < 2
          pc.send_packet(SystemMessageId::AUCTION_ONLY_CLAN_LEVEL_2_HIGHER)
          return
        end

        if val.empty?
          return
        end

        if (clan.auction_bidded_at > 0 && clan.auction_bidded_at != val.to_i) || clan.hideout_id > 0
          pc.send_packet(SystemMessageId::ALREADY_SUBMITTED_BID)
          return
        end

        begin
          filename = "data/html/auction/AgitBid1.htm"

          min_bid = AuctionManager.get_auction(val.to_i).not_nil!.highest_bidder_max_bid
          if min_bid == 0
            min_bid = AuctionManager.get_auction(val.to_i).not_nil!.starting_bid
          end

          html = NpcHtmlMessage.new(l2id)
          html.set_file(pc, filename)
          html["%AGIT_LINK_BACK%"] = "bypass -h npc_#{l2id}_bidding #{val}"
          html["%PLEDGE_ADENA%"] = clan.warehouse.adena
          html["%AGIT_AUCTION_MINBID%"] = min_bid
          html["npc_%objectId%_bid"] = "npc_#{l2id}_bid #{val}"
          pc.send_packet(html)
          return
        rescue
          pc.send_message("Invalid auction")
        end
        return
      elsif actual_cmd.casecmp?("list")
        auctions = AuctionManager.auctions
        format = "%y/%m/%d"
        # Limit for make new page, prevent client crash
        limit = 15
        i = 1
        npage = auctions.size.fdiv(limit).ceil

        if val.empty?
          start = 1
        else
          start = (limit * (val.to_i - 1)) + 1
          limit *= val.to_i
        end

        debug "cmd list: auction test started"

        items = String.build do |io|
          io << "<table width=280 border=0><tr>"
          1.upto(npage) do |j|
            io << "<td><center><a action=\"bypass -h npc_"
            io << l2id
            io << "_list "
            io << j
            io << "\"> Page "
            io << j
            io << " </a></center></td>"
          end

          io << "</tr></table><table width=280 border=0>"

          auctions.each do |a|
            if i > limit
              break
            elsif i < start
              i += 1
              next
            else
              i += 1
            end

            io << "<tr><td>"
            io << ClanHallManager.get_auctionable_hall_by_id(a.item_id).not_nil!.location
            io << "</td><td><a action=\"bypass -h npc_"
            io << l2id
            io << "_bidding "
            io << a.id
            io << "\">"
            io << a.item_name
            io << "</a></td><td>"
            io << Time.from_ms(a.end_date).to_s(format)
            io << "</td><td>"
            io << a.starting_bid
            io << "</td></tr>"
          end

          io << "</table>"
        end
        filename = "data/html/auction/AgitAuctionList.htm"

        html = NpcHtmlMessage.new(l2id)
        html.set_file(pc, filename)
        html["%AGIT_LINK_BACK%"] = "bypass -h npc_#{l2id}_start"
        html["%itemsField%"] = items
        pc.send_packet(html)
        return
      elsif actual_cmd.casecmp?("bidlist")
        auction_id = 0
        if val.empty?
          if pc.clan.not_nil!.auction_bidded_at <= 0
            return
          end
          auction_id = pc.clan.not_nil!.auction_bidded_at
        else
          auction_id = val.to_i
        end

        debug "cmd bidlist: auction test started"

        biders = String.build do |io|
          bidders = AuctionManager.get_auction(auction_id).not_nil!.bidders
          bidders.each_value do |b|
            io << "<tr><td>"
            io << b.clan_name
            io << "</td><td>"
            io << b.name
            io << "</td><td>"
            io << b.time_bid.year
            io << '/'
            io << (b.time_bid.month + 1)
            io << '/'
            io << b.time_bid.day
            io << "</td><td>"
            io << b.bid
            io << "</td></tr>"
          end
        end
        filename = "data/html/auction/AgitBidderList.htm"

        html = NpcHtmlMessage.new(l2id)
        html.set_file(pc, filename)
        html["%AGIT_LIST%"] = biders
        html["%AGIT_LINK_BACK%"] = "bypass -h npc_#{l2id}_selectedItems"
        html["%x%"] = val
        html["%objectId%"] = l2id
        pc.send_packet(html)
        return
      elsif actual_cmd.casecmp?("selectedItems")
        clan = pc.clan
        if clan && clan.hideout_id == 0 && clan.auction_bidded_at > 0
          format = "%d/%m/%Y %H:%M"
          filename = "data/html/auction/AgitBidInfo.htm"
          html = NpcHtmlMessage.new(l2id)
          html.set_file(pc, filename)
          a = AuctionManager.get_auction(clan.auction_bidded_at)
          if a
            html["%AGIT_NAME%"] = a.item_name
            html["%OWNER_PLEDGE_NAME%"] = a.seller_clan_name
            html["%OWNER_PLEDGE_MASTER%"] = a.seller_name
            html["%AGIT_SIZE%"] = ClanHallManager.get_auctionable_hall_by_id(a.item_id).not_nil!.grade * 10
            html["%AGIT_LEASE%"] = ClanHallManager.get_auctionable_hall_by_id(a.item_id).not_nil!.lease
            html["%AGIT_LOCATION%"] = ClanHallManager.get_auctionable_hall_by_id(a.item_id).not_nil!.location
            html["%AGIT_AUCTION_END%"] = Time.from_ms(a.end_date).to_s(format)
            html["%AGIT_AUCTION_REMAIN%"] = "#{(a.end_date - Time.ms) // 3600000} hours #{((a.end_date - Time.ms) // 60000) % 60} minutes"
            html["%AGIT_AUCTION_MINBID%"] = a.starting_bid
            html["%AGIT_AUCTION_MYBID%"] = a.bidders[pc.clan_id].bid
            html["%AGIT_AUCTION_DESC%"] = ClanHallManager.get_auctionable_hall_by_id(a.item_id).not_nil!.desc
            html["%objectId%"] = l2id
            html["%AGIT_LINK_BACK%"] = "bypass -h npc_#{l2id}_start"
          else
            warn "Auctioneer Auction null for AuctionBiddedAt: #{clan.auction_bidded_at}."
          end

          pc.send_packet(html)
          return
        elsif (clan = pc.clan) && AuctionManager.get_auction(clan.hideout_id)
          format = "%d/%m/%Y %H:%M"
          filename = "data/html/auction/AgitSaleInfo.htm"
          html = NpcHtmlMessage.new(l2id)
          html.set_file(pc, filename)
          a = AuctionManager.get_auction(clan.hideout_id)
          if a
            html["%AGIT_NAME%"] = a.item_name
            html["%AGIT_OWNER_PLEDGE_NAME%"] = a.seller_clan_name
            html["%OWNER_PLEDGE_MASTER%"] = a.seller_name
            html["%AGIT_SIZE%"] = ClanHallManager.get_auctionable_hall_by_id(a.item_id).not_nil!.grade * 10
            html["%AGIT_LEASE%"] = ClanHallManager.get_auctionable_hall_by_id(a.item_id).not_nil!.lease
            html["%AGIT_LOCATION%"] = ClanHallManager.get_auctionable_hall_by_id(a.item_id).not_nil!.location
            html["%AGIT_AUCTION_END%"] = Time.from_ms(a.end_date).to_s(format)
            html["%AGIT_AUCTION_REMAIN%"] = "#{(a.end_date - Time.ms) // 3600000} hours #{((a.end_date - Time.ms) // 60000) % 60} minutes"
            html["%AGIT_AUCTION_MINBID%"] = a.starting_bid
            html["%AGIT_AUCTION_BIDCOUNT%"] = a.bidders.size
            html["%AGIT_AUCTION_DESC%"] = ClanHallManager.get_auctionable_hall_by_id(a.item_id).not_nil!.desc
            html["%AGIT_LINK_BACK%"] = "bypass -h npc_#{l2id}_start"
            html["%id%"] = a.id
            html["%objectId%"] = l2id
          else
            warn "Auctioneer Auction null for getHasHideout: #{clan.hideout_id}."
          end

          pc.send_packet(html)
          return
        elsif (clan = pc.clan) && clan.hideout_id != 0
          item_id = clan.hideout_id
          filename = "data/html/auction/AgitInfo.htm"
          html = NpcHtmlMessage.new(l2id)
          html.set_file(pc, filename)
          if ClanHallManager.get_auctionable_hall_by_id(item_id)
            html["%AGIT_NAME%"] = ClanHallManager.get_auctionable_hall_by_id(item_id).not_nil!.name
            html["%AGIT_OWNER_PLEDGE_NAME%"] = clan.name
            html["%OWNER_PLEDGE_MASTER%"] = clan.leader_name
            html["%AGIT_SIZE%"] = ClanHallManager.get_auctionable_hall_by_id(item_id).not_nil!.grade * 10
            html["%AGIT_LEASE%"] = ClanHallManager.get_auctionable_hall_by_id(item_id).not_nil!.lease
            html["%AGIT_LOCATION%"] = ClanHallManager.get_auctionable_hall_by_id(item_id).not_nil!.location
            html["%AGIT_LINK_BACK%"] = "bypass -h npc_#{l2id}_start"
            html["%objectId%"] = l2id
          else
            warn "Clan Hall ID NULL: #{item_id}  Can be caused by concurent write in ClanHallManager"
          end

          pc.send_packet(html)
          return
        elsif (clan = pc.clan) && clan.hideout_id == 0
          pc.send_packet(SystemMessageId::NO_OFFERINGS_OWN_OR_MADE_BID_FOR)
          return
        elsif pc.clan.nil?
          pc.send_packet(SystemMessageId::CANNOT_PARTICIPATE_IN_AN_AUCTION)
          return
        end
      elsif actual_cmd.casecmp?("cancelBid")
        bid = AuctionManager.get_auction(pc.clan.not_nil!.auction_bidded_at).not_nil!.bidders[pc.clan_id].bid
        filename = "data/html/auction/AgitBidCancel.htm"
        html = NpcHtmlMessage.new(l2id)
        html.set_file(pc, filename)
        html["%AGIT_BID%"] = bid
        html["%AGIT_BID_REMAIN%"] = (bid * 0.9).to_i64
        html["%AGIT_LINK_BACK%"] = "bypass -h npc_#{l2id}_selectedItems"
        html["%objectId%"] = l2id
        pc.send_packet(html)
        return
      elsif actual_cmd.casecmp?("doCancelBid")
        if a = AuctionManager.get_auction(pc.clan.not_nil!.auction_bidded_at)
          a.cancel_bid(pc.clan_id)
          pc.send_packet(SystemMessageId::CANCELED_BID)
        end
        return
      elsif actual_cmd.casecmp?("cancelAuction")
        if !pc.has_clan_privilege?(ClanPrivilege::CH_AUCTION)
          filename = "data/html/auction/not_authorized.htm"
          html = NpcHtmlMessage.new(l2id)
          html.set_file(pc, filename)
          html["%objectId%"] = l2id
          pc.send_packet(html)
          return
        end
        filename = "data/html/auction/AgitSaleCancel.htm"
        html = NpcHtmlMessage.new(l2id)
        html.set_file(pc, filename)
        html["%AGIT_DEPOSIT%"] = ClanHallManager.get_clan_hall_by_owner(pc.clan.not_nil!).not_nil!.lease
        html["%AGIT_LINK_BACK%"] = "bypass -h npc_#{l2id}_selectedItems"
        html["%objectId%"] = l2id
        pc.send_packet(html)
        return
      elsif actual_cmd.casecmp?("doCancelAuction")
        if a = AuctionManager.get_auction(pc.clan.not_nil!.hideout_id)
          a.cancel_auction
          pc.send_message("Your auction has been canceled")
        end
        return
      elsif actual_cmd.casecmp?("sale2")
        filename = "data/html/auction/AgitSale2.htm"
        html = NpcHtmlMessage.new(l2id)
        html.set_file(pc, filename)
        html["%AGIT_LAST_PRICE%"] = ClanHallManager.get_clan_hall_by_owner(pc.clan.not_nil!).not_nil!.lease
        html["%AGIT_LINK_BACK%"] = "bypass -h npc_#{l2id}_sale"
        html["%objectId%"] = l2id
        pc.send_packet(html)
        return
      elsif actual_cmd.casecmp?("sale")
        if !pc.has_clan_privilege?(ClanPrivilege::CH_AUCTION)
          filename = "data/html/auction/not_authorized.htm"
          html = NpcHtmlMessage.new(l2id)
          html.set_file(pc, filename)
          html["%objectId%"] = l2id
          pc.send_packet(html)
          return
        end
        filename = "data/html/auction/AgitSale1.htm"
        html = NpcHtmlMessage.new(l2id)
        html.set_file(pc, filename)
        html["%AGIT_DEPOSIT%"] = ClanHallManager.get_clan_hall_by_owner(pc.clan.not_nil!).not_nil!.lease
        html["%AGIT_PLEDGE_ADENA%"] = pc.clan.not_nil!.warehouse.adena
        html["%AGIT_LINK_BACK%"] = "bypass -h npc_#{l2id}_selectedItems"
        html["%objectId%"] = l2id
        pc.send_packet(html)
        return
      elsif actual_cmd.casecmp?("rebid")
        format = "%d/%m/%Y %H:%M"
        if !pc.has_clan_privilege?(ClanPrivilege::CH_AUCTION)
          filename = "data/html/auction/not_authorized.htm"
          html = NpcHtmlMessage.new(l2id)
          html.set_file(pc, filename)
          html["%objectId%"] = l2id
          pc.send_packet(html)
          return
        end
        begin
          filename = "data/html/auction/AgitBid2.htm"
          html = NpcHtmlMessage.new(l2id)
          html.set_file(pc, filename)

          if a = AuctionManager.get_auction(pc.clan.not_nil!.auction_bidded_at)
            html["%AGIT_AUCTION_BID%"] = a.bidders[pc.clan_id].bid
            html["%AGIT_AUCTION_MINBID%"] = a.starting_bid
            html["%AGIT_AUCTION_END%"] = Time.from_ms(a.end_date).to_s(format)
            html["%AGIT_LINK_BACK%"] = "bypass -h npc_#{l2id}_selectedItems"
            html["npc_%objectId%_bid1"] = "npc_#{l2id}_bid1 #{a.id}"
          else
            warn "Auctioneer Auction null for AuctionBiddedAt #{pc.clan.not_nil!.auction_bidded_at}"
          end

          pc.send_packet(html)
        rescue
          pc.send_message("Invalid auction")
        end
        return
      elsif actual_cmd.casecmp?("location")
        html = NpcHtmlMessage.new(l2id)
        html.set_file(pc, "data/html/auction/location.htm")
        html["%location%"] = MapRegionManager.get_closest_town_name(pc)
        html["%LOCATION%"] = get_picture_name(pc)
        html["%AGIT_LINK_BACK%"] = "bypass -h npc_#{l2id}_start"
        pc.send_packet(html)
        return
      elsif actual_cmd.casecmp?("start")
        show_chat_window(pc)
        return
      end
    end

    super
  end

  def show_chat_window(pc : L2PcInstance)
    if validate_condition(pc) == COND_BUSY_BECAUSE_OF_SIEGE
      filename = "data/html/auction/auction-busy.htm"
    else
      filename = "data/html/auction/auction.htm"
    end

    html = NpcHtmlMessage.new(l2id)
    html.set_file(pc, filename)
    html["%objectId%"] = l2id
    html["%npcId%"] = id
    html["%npcname%"] = name
    pc.send_packet(html)
  end

  private def validate_condition(pc : L2PcInstance) : Int32
    castle = castle?
    if castle && castle.residence_id > 0
      if castle.siege.in_progress?
        return COND_BUSY_BECAUSE_OF_SIEGE
      end

      return COND_REGULAR
    end

    COND_ALL_FALSE
  end

  private def get_picture_name(pc : L2PcInstance) : String
    case MapRegionManager.get_map_region_loc_id(pc)
    when 911  then "GLUDIN"
    when 912  then "GLUDIO"
    when 916  then "DION"
    when 918  then "GIRAN"
    when 1537 then "RUNE"
    when 1538 then "GODDARD"
    when 1714 then "SCHUTTGART"
    else "ADEN"
    end
  end
end
