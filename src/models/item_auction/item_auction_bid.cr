class ItemAuctionBid
  setter last_bid : Int64
  getter_initializer player_l2id : Int32, last_bid : Int64

  def cancel_bid
    @last_bid = -1i64
  end

  def cancelled? : Bool
    @last_bid <= 0
  end

  def player : L2PcInstance?
    L2World.get_player(@player_l2id)
  end
end
