class Packets::Incoming::RequestBidItemAuction < GameClientPacket
  @instance_id = 0
  @bid = 0i64

  private def read_impl
    @instance_id = d
    @bid = q
  end

  private def run_impl
    return unless pc = active_char
    unless flood_protectors.transaction.try_perform_action("auction")
      pc.send_message("You are bidding too fast.")
      return
    end

    unless @bid.between?(0, Inventory.max_adena)
      return
    end

    if instance = ItemAuctionManager.get_manager_instance(@instance_id)
      if auction = instance.current_auction
        auction.register_bid(pc, @bid)
      end
    end
  end
end
