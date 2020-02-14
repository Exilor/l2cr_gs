class Packets::Incoming::RequestInfoItemAuction < GameClientPacket
  @instance_id = 0

  private def read_impl
    @instance_id = d
  end

  private def run_impl
    return unless pc = active_char

    unless flood_protectors.item_auction.try_perform_action("RequestInfoItemAuction")
      return
    end

    unless instance = ItemAuctionManager.get_manager_instance(@instance_id)
      return
    end
    unless auction = instance.current_auction
      return
    end

    pc.update_last_item_auction_request
    packet = ExItemAuctionInfoPacket.new(true, auction, instance.next_auction)
    pc.send_packet(packet)
  end
end
