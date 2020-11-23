class Auction
  include Loggable
  include Synchronizable

  private ITEM_TYPE_NAME = {"ClanHall"}

  getter id = 0
  getter end_date = 0i64
  getter highest_bidder_id = 0
  getter highest_bidder_name = ""
  getter highest_bidder_max_bid = 0i64
  getter item_id = 0
  getter item_name = ""
  getter item_l2id = 0
  getter item_quantity = 0i64
  getter item_type = ""
  getter seller_id = 0
  getter seller_clan_name = ""
  getter seller_name = ""
  getter current_bid = 0i64
  getter starting_bid = 0i64
  getter bidders = Concurrent::Map(Int32, Bidder).new

  def initialize(id : Int32)
    @id = id
    load
    start_auto_task
  end

  def initialize(id : Int32, clan : L2Clan, delay : Int64, starting_bid : Int64, item_name : String)
    @id = id
    @starting_bid = starting_bid
    @item_name = item_name
    @end_date = Time.ms + delay
    @item_type = "ClanHall"
    @seller_id = clan.leader_id
    @seller_name = clan.leader_name
    @seller_clan_name = clan.name
  end

  private def load
    sql = "SELECT * FROM auction WHERE id = ?"
    GameDB.each(sql, id) do |rs|
      @current_bid = rs.get_i64(:"currentBid")
      @end_date = rs.get_i64(:"endDate")
      @item_id = rs.get_i32(:"itemId")
      @item_name = rs.get_string(:"itemName")
      @item_l2id = rs.get_i32(:"itemObjectId")
      @item_type = rs.get_string(:"itemType")
      @seller_id = rs.get_i32(:"sellerId")
      @seller_clan_name = rs.get_string(:"sellerClanName")
      @seller_name = rs.get_string(:"sellerName")
      @starting_bid = rs.get_i64(:"startingBid")
    end
    load_bid
  rescue e
    error e
  end

  private def load_bid
    @highest_bidder_id = 0
    @highest_bidder_name = ""
    @highest_bidder_max_bid = 0i64
    first = true
    sql = "SELECT bidderId, bidderName, maxBid, clan_name, time_bid FROM auction_bid WHERE auctionId = ? ORDER BY maxBid DESC"
    GameDB.each(sql, id) do |rs|
      if first
        @highest_bidder_id = rs.get_i32(:"bidderId")
        @highest_bidder_name = rs.get_string(:"bidderName")
        @highest_bidder_max_bid = rs.get_i64(:"maxBid")
        first = false
      end

      bidder_id = rs.get_i32(:"bidderId")
      bidder_name = rs.get_string(:"bidderName")
      clan_name = rs.get_string(:"clan_name")
      max_bid = rs.get_i64(:"maxBid")
      time_bid = rs.get_i64(:"time_bid")
      bidder = Bidder.new(bidder_name, clan_name, max_bid, time_bid)
      @bidders[bidder_id] = bidder
    end
  rescue e
    error e
  end

  private def start_auto_task
    time = Time.ms
    delay = 0i64
    if @end_date <= time
      @end_date = time + (7i64 * 24 * 3_600_000)
      save_auction_date
    else
      delay = @end_date - time
    end

    ThreadPoolManager.schedule_general(AutoEndTask.new(self), delay)
  end

  def self.get_item_type_name(value : AuctionItemType) : String
    ITEM_TYPE_NAME[value.to_i]
  end

  private def save_auction_date
    sql = "UPDATE auction SET endDate = ? WHERE id = ?"
    GameDB.exec(sql, @end_date, @id)
  rescue e
    error e
  end

  def set_bid(bidder : L2PcInstance, bid : Int64)
    sync do
      required_adena = bid
      if highest_bidder_name == bidder.clan.not_nil!.leader_name
        required_adena = bid - highest_bidder_max_bid
      end

      if (highest_bidder_id > 0 && bid > highest_bidder_max_bid) || (highest_bidder_id == 0 && bid >= starting_bid)
        if take_item(bidder, required_adena)
          update_in_db(bidder, bid)
          bidder.clan.not_nil!.set_auction_bidded_at(@id, true)
          return
        end
      end

      if bid < starting_bid || bid <= highest_bidder_max_bid
        bidder.send_packet(SystemMessageId::BID_PRICE_MUST_BE_HIGHER)
      end
    end
  end

  private def return_item(clan_name : String, quantity : Int64, penalty : Bool)
    if penalty
      quantity *= 0.9
    end

    unless clan = ClanTable.get_clan_by_name(clan_name)
      warn { "Clan '#{clan_name}' not found." }
      return
    end

    cwh = clan.warehouse
    limit = Inventory.max_adena - cwh.adena
    quantity = Math.min(quantity, limit)

    cwh.add_item("Outbidded", Inventory::ADENA_ID, quantity.to_i64, nil, nil)
  end

  private def take_item(bidder : L2PcInstance, quantity : Int64) : Bool
    clan = bidder.clan
    if clan && clan.warehouse.adena >= quantity
      clan.warehouse.destroy_item_by_item_id("Buy", Inventory::ADENA_ID, quantity, bidder, bidder)
      return true
    end

    bidder.send_packet(SystemMessageId::NOT_ENOUGH_ADENA_IN_CWH)
    false
  end

  private def update_in_db(bidder : L2PcInstance, bid : Int64)
    begin
      if @bidders.has_key?(bidder.clan_id)
        sql = "UPDATE auction_bid SET bidderId=?, bidderName=?, maxBid=?, time_bid=? WHERE auctionId=? AND bidderId=?"
        GameDB.exec(sql, bidder.clan_id, bidder.clan.not_nil!.leader_name, bid, Time.ms, id, bidder.clan_id)
      else
        sql = "INSERT INTO auction_bid (id, auctionId, bidderId, bidderName, maxBid, clan_name, time_bid) VALUES (?, ?, ?, ?, ?, ?, ?)"
        GameDB.exec(sql, IdFactory.next, id, bidder.clan_id, bidder.name, bid, bidder.clan.not_nil!.name, Time.ms)
      end
    rescue e
      error e
      return
    end

    if pc = L2World.get_player(@highest_bidder_name)
      pc.send_message("You have been outbidded.")
    end

    @highest_bidder_id = bidder.clan_id
    @highest_bidder_max_bid = bid
    @highest_bidder_name = bidder.clan.not_nil!.leader_name

    if tmp = @bidders[@highest_bidder_id]?
      tmp.bid = bid
      tmp.time_bid = Time.ms
    else
      tmp = Bidder.new(@highest_bidder_name, bidder.clan.not_nil!.name, bid, Time.ms)
      @bidders[@highest_bidder_id] = tmp
    end

    bidder.send_packet(SystemMessageId::BID_IN_CLANHALL_AUCTION)
  end

  private def remove_bids
    begin
      sql = "DELETE FROM auction_bid WHERE auctionId=?"
      GameDB.exec(sql, id)
    rescue e
      error e
    end

    @bidders.each_value do |b|
      if ClanTable.get_clan_by_name(b.clan_name).not_nil!.hideout_id == 0
        return_item(b.clan_name, b.bid, true)
      else
        if pc = L2World.get_player(b.name)
          pc.send_message("You have won the auction for a clan hall.")
        end
      end

      ClanTable.get_clan_by_name(b.clan_name).not_nil!.set_auction_bidded_at(0, true)
    end

    @bidders.clear
  end

  def delete_auction_from_db
    AuctionManager.auctions.delete(self)
    sql = "DELETE FROM auction WHERE itemId=?"
    GameDB.exec(sql, @item_id)
  rescue e
    error e
  end

  def end_auction
    if ClanHallManager.loaded?
      if @highest_bidder_id == 0 && @seller_id == 0
        start_auto_task
        return
      end

      if @highest_bidder_id == 0 && @seller_id > 0
        idx = AuctionManager.get_auction_index(@id)
        AuctionManager.auctions.delete_at(idx)
        return
      end

      if @seller_id > 0
        return_item(@seller_clan_name, @highest_bidder_max_bid, true)
        hall = ClanHallManager.get_auctionable_hall_by_id(@item_id).not_nil!
        return_item(@seller_clan_name, hall.lease.to_i64, false)
      end

      delete_auction_from_db
      clan = ClanTable.get_clan_by_name(@bidders[@highest_bidder_id].clan_name).not_nil!
      @bidders.delete(@highest_bidder_id)
      clan.set_auction_bidded_at(0, true)
      remove_bids
      ClanHallManager.set_owner(@item_id, clan)
    else
      ThreadPoolManager.schedule_general(AutoEndTask.new(self), 3000)
    end
  end

  def cancel_bid(bidder : Int32)
    sync do
      begin
        sql = "DELETE FROM auction_bid WHERE auctionId=? AND bidderId=?"
        GameDB.exec(sql, id, bidder)
      rescue e
        error e
      end

      bidder = @bidders[bidder]
      return_item(bidder.clan_name, bidder.bid, true)
      ClanTable.get_clan_by_name(bidder.clan_name).not_nil!.set_auction_bidded_at(0, true)
      @bidders.clear
      load_bid
    end
  end

  def cancel_auction
    delete_auction_from_db
    remove_bids
  end

  def confirm_auction
    AuctionManager.auctions << self

    sql = "INSERT INTO auction (id, sellerId, sellerName, sellerClanName, itemType, itemId, itemObjectId, itemName, itemQuantity, startingBid, currentBid, endDate) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)"
    GameDB.exec(
      sql,
      id,
      @seller_id,
      @seller_name,
      @seller_clan_name,
      @item_type,
      @item_id,
      @item_l2id,
      @item_name,
      @item_quantity,
      @starting_bid,
      @current_bid,
      @end_date
    )
  rescue e
    error e
  end

  private class Bidder
    getter name, clan_name, time_bid
    property bid : Int64

    def initialize(name : String, clan_name : String, bid : Int64, time_bid : Int64)
      @name = name
      @clan_name = clan_name
      @bid = bid
      @time_bid = Calendar.new
      @time_bid.ms = time_bid
    end

    def time_bid=(ms : Int64)
      @time_bid.ms = ms
    end
  end

  private struct AutoEndTask
    include Loggable

    initializer auction : Auction

    def call
      @auction.end_auction
    rescue e
      error e
    end
  end
end
