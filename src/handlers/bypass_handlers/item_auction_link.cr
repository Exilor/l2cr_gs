module BypassHandler
  module ItemAuctionLink
    extend self
    extend BypassHandler

    def use_bypass(command, pc, target)
      unless target.is_a?(L2Npc)
        return false
      end

      unless Config.alt_item_auction_enabled
        pc.send_packet(SystemMessageId::NO_AUCTION_PERIOD)
        return true
      end

      unless au = ItemAuctionManager.get_manager_instance(target.id)
        debug { "No auction with id #{target.id} found." }
        return false
      end

      begin
        st = command.split
        st.shift
        if st.empty?
          return false
        end

        cmd = st.shift

        if cmd.casecmp?("show")
          unless pc.flood_protectors.item_auction.try_perform_action("RequestInfoItemAuction")
            return false
          end

          if pc.item_auction_polling?
            return false
          end

          current_auction = au.current_auction
          next_auction = au.next_auction

          unless current_auction
            pc.send_packet(SystemMessageId::NO_AUCTION_PERIOD)
            if next_auction
              time = Time.from_ms(next_auction.starting_time)
              pc.send_message("The next auction will begin on the #{time}.")
            end

            return true
          end

          next_auction = next_auction.not_nil!

          pk = ExItemAuctionInfoPacket.new(false, current_auction, next_auction)
          pc.send_packet(pk)
        elsif cmd.casecmp?("cancel")
          auctions = au.get_auctions_by_bidder(pc.l2id)
          returned = false
          auctions.each do |auction|
            if auction.cancel_bid(pc)
              returned = true
            end
          end
          unless returned
            pc.send_packet(SystemMessageId::NO_OFFERINGS_OWN_OR_MADE_BID_FOR)
          end
        else
          return false
        end
      rescue e
        error e
      end

      true
    end

    def commands
      {"ItemAuction"}
    end
  end
end
