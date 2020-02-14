class Packets::Outgoing::ExItemAuctionInfoPacket < Packets::Outgoing::AbstractItemPacket
  def initialize(@refresh : Bool, @current_auction : ItemAuction, @next_auction : ItemAuction?)
    if current_auction.auction_state.started?
      @time_remaining = (current_auction.finishing_time_remaining / 1000).to_i
    else
      @time_remaining = 0
    end
  end

  private def write_impl
    c 0xfe
    h 0x68

    c @refresh ? 0 : 1
    d @current_auction.instance_id
    highest_bid = @current_auction.highest_bid
    q highest_bid ? highest_bid.last_bid : @current_auction.auction_init_bid

    d @time_remaining
    write_item(@current_auction.item_info)

    if next_auction = @next_auction
      q next_auction.auction_init_bid
      d (next_auction.starting_time / 1000).to_i
      write_item(next_auction.item_info)
    end
  end
end
