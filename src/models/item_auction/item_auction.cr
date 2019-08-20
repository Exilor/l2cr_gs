require "./item_auction_bid"
require "./item_auction_extend_state"
require "./item_auction_state"

class ItemAuction
  include Loggable
  private ENDING_TIME_EXTEND_5 = Time.mins_to_ms(5)
  private ENDING_TIME_EXTEND_3 = Time.mins_to_ms(3)

  @auction_bids_lock = Mutex.new
  @auction_state_lock = Mutex.new
  @last_bid_player_l2id = 0
  getter highest_bid : ItemAuctionBid?
  getter auction_ending_extend_state = ItemAuctionExtendState::INITIAL
  getter auction_id, instance_id, starting_time, ending_time, item_info
  property scheduled_auction_ending_extend_state : ItemAuctionExtendState = ItemAuctionExtendState::INITIAL

  # SQL
  private DELETE_ITEM_AUCTION_BID = "DELETE FROM item_auction_bid WHERE auctionId = ? AND playerObjId = ?"
  private INSERT_ITEM_AUCTION_BID = "INSERT INTO item_auction_bid (auctionId, playerObjId, playerBid) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE playerBid = ?"

  def initialize(auction_id : Int32, instance_id : Int32, starting_time : Int64, ending_time : Int64, auction_item : AuctionItem)
    initialize(auction_id, instance_id, starting_time, ending_time, auction_item, ([] of ItemAuctionBid), ItemAuctionState::CREATED)
  end

  def initialize(auction_id : Int32, instance_id : Int32, starting_time : Int64, ending_time : Int64, auction_item : AuctionItem, auction_bids : Array(ItemAuctionBid), auction_state : ItemAuctionState)
    @auction_id = auction_id
    @instance_id = instance_id
    @starting_time = starting_time
    @ending_time = ending_time
    @auction_item = auction_item
    @auction_bids = auction_bids
    @auction_state = auction_state

    item = @auction_item.create_new_item_instance
    @item_info = ItemInfo.new(item)
    L2World.remove_object(item)

    @auction_bids.each do |bid|
      if @highest_bid.nil? || @highest_bid.not_nil!.last_bid < bid.last_bid
        @highest_bid = bid
      end
    end
  end

  def auction_state : ItemAuctionState
    @auction_state_lock.synchronize do
      @auction_state
    end
  end

  def set_auction_state(expected : ItemAuctionState, wanted : ItemAuctionState) : Bool
    @auction_state_lock.synchronize do
      if @auction_state != expected
        return false
      end

      @auction_state = wanted
      store_me
      true
    end
  end

  def create_new_item_instance : L2ItemInstance
    @auction_item.create_new_item_instance
  end

  def auction_init_bid
    @auction_item.auction_init_bid
  end

  def starting_time_remaining
    Math.max(ending_time - Time.ms, 0)
  end

  def finishing_time_remaining
    Math.max(ending_time - Time.ms, 0)
  end

  def store_me
    sql = "INSERT INTO item_auction (auctionId,instanceId,auctionItemId,startingTime,endingTime,auctionStateId) VALUES (?,?,?,?,?,?) ON DUPLICATE KEY UPDATE auctionStateId=?"
    GameDB.exec(
      sql,
      @auction_id,
      @instance_id,
      @auction_item.auction_item_id,
      @starting_time,
      @ending_time,
      @auction_state.state_id,
      @auction_state.state_id
    )
  rescue e
    error e
  end

  def get_and_set_last_bid_player_l2id(player_l2id : Int32)
    last_bid = @last_bid_player_l2id
    @last_bid_player_l2id = player_l2id
    last_bid
  end

  private def update_player_bid(bid : ItemAuctionBid, delete : Bool)
    update_player_bid_internal(bid, delete)
  end

  def update_player_bid_internal(bid : ItemAuctionBid, delete : Bool)
    if delete
      sql = DELETE_ITEM_AUCTION_BID
      GameDB.exec(sql, @auction_id, bid.player_l2id)
    else
      sql = INSERT_ITEM_AUCTION_BID
      GameDB.exec(sql, @auction_id, bid.player_l2id, bid.last_bid, bid.last_bid)
    end
  rescue e
    error e
  end

  def register_bid(player, new_bid)
    player = player.not_nil!

    if new_bid < auction_init_bid
      player.send_packet(SystemMessageId::BID_PRICE_MUST_BE_HIGHER)
      return
    end

    if new_bid > 100000000000
      player.send_packet(SystemMessageId::BID_CANT_EXCEED_100_BILLION)
      return
    end

    unless auction_state.started?
      return
    end

    player_l2id = player.l2id

    @auction_bids_lock.synchronize do
      if @highest_bid && new_bid < @highest_bid.not_nil!.last_bid
        player.send_packet(SystemMessageId::BID_MUST_BE_HIGHER_THAN_CURRENT_BID)
        return
      end

      bid = get_bid_for(player_l2id)
      if bid.nil?
        unless reduce_item_count(player, new_bid)
          player.send_packet(SystemMessageId::NOT_ENOUGH_ADENA_FOR_THIS_BID)
          return
        end

        bid = ItemAuctionBid.new(player_l2id, new_bid)
        @auction_bids << bid
      else
        if !bid.cancelled?
          if new_bid < bid.last_bid # just another check
            player.send_packet(SystemMessageId::BID_MUST_BE_HIGHER_THAN_CURRENT_BID)
            return
          end

          unless reduce_item_count(player, new_bid - bid.last_bid)
            player.send_packet(SystemMessageId::NOT_ENOUGH_ADENA_FOR_THIS_BID)
            return
          end
        elsif !reduce_item_count(player, new_bid)
          player.send_packet(SystemMessageId::NOT_ENOUGH_ADENA_FOR_THIS_BID)
          return
        end

        bid.last_bid = new_bid
      end

      on_player_bid(player, bid)
      update_player_bid(bid, false)

      sm = SystemMessage.submitted_a_bid_of_s1
      sm.add_long(new_bid)
      player.send_packet(sm)
      return
    end
  end

  private def on_player_bid(player, bid : ItemAuctionBid)
    if @highest_bid.nil?
      @highest_bid = bid
    elsif @highest_bid.not_nil!.last_bid < bid.last_bid
      if old = @highest_bid.not_nil!.player
        old.send_packet(SystemMessageId::YOU_HAVE_BEEN_OUTBID)
      end

      @highest_bid = bid
    end

    if ending_time - Time.ms <= 1000 * 60 * 10 # 10 minutes
      case @auction_ending_extend_state
      when ItemAuctionExtendState::INITIAL
        @auction_ending_extend_state = ItemAuctionExtendState::EXTEND_BY_5_MIN
        @ending_time += ENDING_TIME_EXTEND_5
        broadcast_to_all_bidders(SystemMessage.bidder_exists_auction_time_extended_by_5_minutes)
      when ItemAuctionExtendState::EXTEND_BY_5_MIN
        if get_and_set_last_bid_player_l2id(player.l2id) != player.l2id
          @auction_ending_extend_state = ItemAuctionExtendState::EXTEND_BY_3_MIN
          @ending_time += ENDING_TIME_EXTEND_3
          broadcast_to_all_bidders(SystemMessage.bidder_exists_auction_time_extended_by_3_minutes)
        end
      when ItemAuctionExtendState::EXTEND_BY_3_MIN
        if Config.alt_item_auction_time_extends_on_bid > 0
          if get_and_set_last_bid_player_l2id(player.l2id) != player.l2id
            @auction_ending_extend_state = ItemAuctionExtendState::EXTEND_BY_CONFIG_PHASE_A
            @ending_time += Config.alt_item_auction_time_extends_on_bid
          end
        end
      when ItemAuctionExtendState::EXTEND_BY_CONFIG_PHASE_A
        if get_and_set_last_bid_player_l2id(player.l2id) != player.l2id
          if @scheduled_auction_ending_extend_state == ItemAuctionExtendState::EXTEND_BY_CONFIG_PHASE_B
            @auction_ending_extend_state = ItemAuctionExtendState::EXTEND_BY_CONFIG_PHASE_B
            @ending_time += Config.alt_item_auction_time_extends_on_bid
          end
        end
      when ItemAuctionExtendState::EXTEND_BY_CONFIG_PHASE_B
        if get_and_set_last_bid_player_l2id(player.l2id) != player.l2id
          if @scheduled_auction_ending_extend_state == ItemAuctionExtendState::EXTEND_BY_CONFIG_PHASE_A
            @ending_time += Config.alt_item_auction_time_extends_on_bid
            @auction_ending_extend_state = ItemAuctionExtendState::EXTEND_BY_CONFIG_PHASE_A
          end
        end
      end
    end
  end

  def broadcast_to_all_bidders(gsp : GameServerPacket)
    task = ->{ broadcast_to_all_bidders_internal(gsp) }
    ThreadPoolManager.execute_general(task)
  end

  def broadcast_to_all_bidders_internal(gsp : GameServerPacket)
    @auction_bids.reverse_each do |bid|
      if pc = bid.player
        pc.send_packet(gsp)
      end
    end
  end

  def cancel_bid(player)
    player = player.not_nil!

    case auction_state
    when ItemAuctionState::CREATED
      return false
    when ItemAuctionState::FINISHED
      if @starting_time < Time.ms - Time.days_to_ms(Config.alt_item_auction_expired_after)
        return false
      end
    end

    player_l2id = player.l2id

    @auction_bids_lock.synchronize do
      if @highest_bid.nil?
        return false
      end

      bid_index = get_bid_index_for(player_l2id)
      if bid_index == -1
        return false
      end

      bid = @auction_bids[bid_index]
      if bid.player_l2id == @highest_bid.not_nil!.player_l2id
        # can't return winning bid
        if auction_state.finished?
          return false
        end

        player.send_packet(SystemMessageId::HIGHEST_BID_BUT_RESERVE_NOT_MET)
        return true
      end

      if bid.cancelled?
        return false
      end

      increase_item_count(player, bid.last_bid)
      bid.cancel_bid

      # delete bid from database if auction already finished
      update_player_bid(bid, auction_state.finished?)

      player.send_packet(SystemMessageId::CANCELED_BID)
    end

    true
  end

  def clear_cancelled_bids
    unless auction_state.finished?
      raise "Attempt to clear canceled bids for non-finished auction"
    end

    @auction_bids_lock.synchronize do
      @auction_bids.each do |bid|
        if bid.nil? || !bid.cancelled?
          next
        end
        update_player_bid(bid, true)
      end
    end
  end

  private def reduce_item_count(player, count)
    unless player.reduce_adena("ItemAuction", count, player, true)
      player.send_packet(SystemMessageId::NOT_ENOUGH_ADENA_FOR_THIS_BID)
      return false
    end

    true
  end

  private def increase_item_count(player, count)
    player.add_adena("ItemAuction", count, player, true)
  end

  def get_last_bid(player)
    bid = get_bid_for(player.l2id)
    bid ? bid.last_bid : -1i64
  end

  def get_bid_for(player_l2id : Int32) : ItemAuctionBid?
    index = get_bid_index_for(player_l2id)
    index != -1 ? @auction_bids[index]? : nil
  end

  private def get_bid_index_for(player_l2id : Int32) : Int32
    (@auction_bids.size - 1).downto(0) do |i|
      bid = @auction_bids[i]
      if bid.player_l2id == player_l2id
        return i
      end
    end

    -1
  end
end
