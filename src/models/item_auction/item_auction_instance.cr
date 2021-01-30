require "./auction_date_generator"
require "./item_auction"
require "./auction_item"

class ItemAuctionInstance
  include Loggable
  include Packets::Outgoing
  include XMLReader

  private DATE_FORMAT = "%H:%m:%S %d.%m.%y"

  private START_TIME_SPACE = Time.mins_to_ms(1)
  private FINISH_TIME_SPACE = Time.mins_to_ms(10)

  # SQL queries
  private SELECT_AUCTION_ID_BY_INSTANCE_ID = "SELECT auctionId FROM item_auction WHERE instanceId = ?"
  private SELECT_AUCTION_INFO = "SELECT auctionItemId, startingTime, endingTime, auctionStateId FROM item_auction WHERE auctionId = ? "
  private DELETE_AUCTION_INFO_BY_AUCTION_ID = "DELETE FROM item_auction WHERE auctionId = ?"
  private DELETE_AUCTION_BID_INFO_BY_AUCTION_ID = "DELETE FROM item_auction_bid WHERE auctionId = ?"
  private SELECT_PLAYERS_ID_BY_AUCTION_ID = "SELECT playerObjId, playerBid FROM item_auction_bid WHERE auctionId = ?"

  @auctions = {} of Int32 => ItemAuction
  @auctions_lock = MyMutex.new
  @items = [] of AuctionItem
  @state_task : TaskScheduler::DelayedTask?

  getter current_auction : ItemAuction?
  getter next_auction : ItemAuction?

  def initialize(instance_id : Int32, auction_ids : Atomic(Int32), node)
    @instance_id = instance_id
    @auction_ids = auction_ids
    generator_config = get_attributes(node)

    @date_generator = AuctionDateGenerator.new(generator_config)

    find_element(node, "item") do |na|
      begin
        auction_item_id = parse_int(na, "auctionItemId")
        auction_lenght = parse_int(na, "auctionLenght")
        auction_init_bid = parse_long(na, "auctionInitBid")

        item_id = parse_int(na, "itemId")
        item_count = parse_long(na, "itemCount")

        if auction_lenght < 1
          raise "auctionLenght < 1 for instance_id: #{@instance_id}, item_id: #{item_id}"
        end

        item_extra = StatsSet.new
        item = AuctionItem.new(auction_item_id, auction_lenght, auction_init_bid, item_id, item_count, item_extra)

        unless item.check_item_exists
          raise "Item with id #{item_id} not found"
        end

        @items.each do |tmp|
          if tmp.auction_item_id == auction_item_id
            raise "Duplicated auction item id #{auction_item_id}"
          end
        end

        @items << item

        find_element(na, "extra") do |nb|
          item_extra.merge!(get_attributes(nb))
        end
      rescue e
        error e
      end
    end

    if @items.empty?
      raise "No items defined"
    end

    begin
      GameDB.each(SELECT_AUCTION_ID_BY_INSTANCE_ID, @instance_id) do |rs|
        auction_id = rs.get_i32(1)
        begin
          if auction = load_auction(auction_id)
            @auctions[auction_id] = auction
          else
            ItemAuctionManager.delete_auction(auction_id)
          end
        rescue e
          error e
        end
      end
    rescue e
      error e
      return
    end

    info { "Loaded #{@items.size} item(s) and registered #{@auctions.size} auction(s) for NPC ID #{@instance_id}." }
    check_and_set_current_and_next_auction
  end

  def shutdown
    if task = @state_task
      task.cancel
    end
  end

  private def get_auction_item(auction_item_id : Int32) : AuctionItem?
    @items.reverse_each do |item|
      if item.auction_item_id == auction_item_id
        return item
      end
    end
  end

  def check_and_set_current_and_next_auction
    auctions = @auctions.values_slice

    current_auction = nil
    next_auction = nil

    case auctions.size
    when 0
      next_auction = create_auction(Time.ms + START_TIME_SPACE)
    when 1
      case auctions[0].auction_state
      when ItemAuctionState::CREATED
        if auctions[0].starting_time < Time.ms + START_TIME_SPACE
          current_auction = auctions[0]
          next_auction = create_auction(Time.ms + START_TIME_SPACE)
        else
          next_auction = auctions[0]
        end
      when ItemAuctionState::STARTED
        current_auction = auctions[0]
        next_auction = create_auction(Math.max(current_auction.ending_time + FINISH_TIME_SPACE, Time.ms + START_TIME_SPACE))
      when ItemAuctionState::FINISHED
        current_auction = auctions[0]
        next_auction = create_auction(Time.ms + START_TIME_SPACE)
      else
        raise "Invalid state #{auctions[0].auction_state}"
      end
    else
      auctions.sort_by! &.starting_time

      # just to make sure we won't skip any auction because of little different times
      time = Time.ms

      auctions.reverse_each do |auction|
        if auction.auction_state.started?
          current_auction = auction
          break
        elsif auction.starting_time <= time
          current_auction = auction
          break # only first
        end
      end

      auctions.reverse_each do |auction|
        if auction.starting_time > time && current_auction != auction
          next_auction = auction
          break
        end
      end

      unless next_auction
        next_auction = create_auction(Time.ms + START_TIME_SPACE)
      end
    end

    @auctions[next_auction.auction_id] = next_auction

    @current_auction = current_auction
    @next_auction = next_auction

    if current_auction && !current_auction.auction_state.finished?
      if current_auction.auction_state.started?
        self.state_task = ThreadPoolManager.schedule_general(ScheduleAuctionTask.new(self, current_auction), Math.max(current_auction.ending_time - Time.ms, 0))
      else
        self.state_task = ThreadPoolManager.schedule_general(ScheduleAuctionTask.new(self, current_auction), Math.max(current_auction.starting_time - Time.ms, 0))
      end

      info { "Scheduled current auction ID #{current_auction.auction_id} for NPC ID #{@instance_id}." }
    else
      self.state_task = ThreadPoolManager.schedule_general(ScheduleAuctionTask.new(self, next_auction), Math.max(next_auction.starting_time - Time.ms, 0))
      info { "Scheduled next auction ID #{next_auction.auction_id} on #{Time.now.to_s(DATE_FORMAT)} for NPC ID #{@instance_id}." }
    end
  end

  def get_auction(auction_id : Int32) : ItemAuction?
    @auctions[auction_id]?
  end

  def get_auctions_by_bidder(bidder_l2id : Int32) : Array(ItemAuction)
    ret = Array(ItemAuction).new(@auctions.size)
    auctions.each do |auction|
      unless auction.auction_state.created?
        if auction.get_bid_for(bidder_l2id)
          ret << auction
        end
      end
    end

    ret
  end

  def auctions : Enumerable(ItemAuction)
    @auctions_lock.synchronize do
      @auctions.values_slice
    end
  end

  private struct ScheduleAuctionTask
    include Loggable

    initializer instance : ItemAuctionInstance, auction : ItemAuction

    def call
      run_impl
    rescue e
      error e
    end

    private def run_impl
      case state = @auction.auction_state
      when ItemAuctionState::CREATED
        unless @auction.set_auction_state(state, ItemAuctionState::STARTED)
          raise "Could not set auction state: #{ItemAuctionState::STARTED}, expected: #{state}"
        end

        info { "Auction ID #{@auction.auction_id} has started for NPC ID #{@auction.instance_id}." }
        @instance.check_and_set_current_and_next_auction
      when ItemAuctionState::STARTED
        case @auction.auction_ending_extend_state
        when ItemAuctionExtendState::EXTEND_BY_5_MIN
          if @auction.scheduled_auction_ending_extend_state.initial?
            @auction.scheduled_auction_ending_extend_state = ItemAuctionExtendState::EXTEND_BY_5_MIN
            @instance.state_task = ThreadPoolManager.schedule_general(self, Math.max(@auction.ending_time - Time.ms, 0))
            return
          end
        when ItemAuctionExtendState::EXTEND_BY_3_MIN
          unless @auction.scheduled_auction_ending_extend_state.extend_by_3_min?
            @auction.scheduled_auction_ending_extend_state = ItemAuctionExtendState::EXTEND_BY_3_MIN
            @instance.state_task = ThreadPoolManager.schedule_general(self, Math.max(@auction.ending_time - Time.ms, 0))
            return
          end
        when ItemAuctionExtendState::EXTEND_BY_CONFIG_PHASE_A
          unless @auction.scheduled_auction_ending_extend_state.extend_by_config_phase_b?
            @auction.scheduled_auction_ending_extend_state = ItemAuctionExtendState::EXTEND_BY_CONFIG_PHASE_B
            @instance.state_task = ThreadPoolManager.schedule_general(self, Math.max(@auction.ending_time - Time.ms, 0))
            return
          end
        when ItemAuctionExtendState::EXTEND_BY_CONFIG_PHASE_B
          unless @auction.scheduled_auction_ending_extend_state.extend_by_config_phase_a?
            @auction.scheduled_auction_ending_extend_state = ItemAuctionExtendState::EXTEND_BY_CONFIG_PHASE_A
            @instance.state_task = ThreadPoolManager.schedule_general(self, Math.max(@auction.ending_time - Time.ms, 0))
            return
          end
        end


        unless @auction.set_auction_state(state, ItemAuctionState::FINISHED)
          raise "Could not set auction state: #{ItemAuctionState::FINISHED}, expected: #{state}"
        end

        @instance.on_auction_finished(@auction)
        @instance.check_and_set_current_and_next_auction
      else
        raise "Invalid state: #{state}"
      end
    end
  end

  def on_auction_finished(auction : ItemAuction)
    sm = SystemMessage.s1_auction_ended
    sm.add_int(auction.auction_id)
    auction.broadcast_to_all_bidders_internal(sm)

    if bid = auction.highest_bid
      item = auction.create_new_item_instance
      if pc = bid.player
        pc.warehouse.add_item("ItemAuction", item, nil, nil)
        pc.send_packet(SystemMessageId::WON_BID_ITEM_CAN_BE_FOUND_IN_WAREHOUSE)
        info { "Auction ID #{auction.auction_id} has finished. Highest bid by #{pc.name} for instance ID #{@instance_id}." }
      else
        item.owner_id = bid.player_l2id
        item.item_location = ItemLocation::WAREHOUSE
        item.update_database
        L2World.remove_object(item)

        pc_name = CharNameTable.get_name_by_id(bid.player_l2id)
        info { "Auction ID #{auction.auction_id} has finished. Highest bid by #{pc_name} for instance ID #{@instance_id}." }
      end

      auction.clear_cancelled_bids
    else
      info { "Auction ID #{auction.auction_id} has finished. There hasn't been any bid for instance ID #{@instance_id}." }
    end
  end

  def state_task=(new_task : TaskScheduler::DelayedTask)
    if state_task = @state_task
      state_task.cancel
    end

    @state_task = new_task
  end

  private def create_auction(after) : ItemAuction
    auction_item = @items.sample(random: Rnd)
    starting_time = @date_generator.next_date(after)
    ending_time = starting_time + Time.mins_to_ms(auction_item.auction_length)
    auction = ItemAuction.new(@auction_ids.add(1) + 1, @instance_id, starting_time, ending_time, auction_item)
    auction.store_me
    auction
  end

  private def load_auction(auction_id : Int32) : ItemAuction?
    auction_item_id = 0
    starting_time = 0i64
    ending_time = 0i64
    auction_state_id = 0i8
    found = false
    GameDB.each(SELECT_AUCTION_INFO, auction_id) do |rs|
      found = true
      auction_item_id = rs.get_i32(1)
      starting_time = rs.get_i64(2)
      ending_time = rs.get_i64(3)
      auction_state_id = rs.get_i8(4)
    end
    unless found
      warn { "Auction data not found for auction ID #{auction_id}." }
      return
    end

    if starting_time >= ending_time
      warn { "Invalid starting/ending paramaters for auction ID #{auction_id}." }
      return
    end

    auction_item = get_auction_item(auction_item_id)
    unless auction_item
      warn { "Auction item ID #{auction_item_id} not found for auction ID #{auction_id}." }
      return
    end

    auction_state = ItemAuctionState.state_for_state_id(auction_state_id)
    unless auction_state
      warn { "Invalid auction state ID #{auction_state_id} for auction ID #{auction_id}." }
      return
    end

    if auction_state.finished? && starting_time < Time.ms - Time.days_to_ms(Config.alt_item_auction_expired_after)
      info { "Clearing expired auction ID #{auction_id}." }
      GameDB.exec(DELETE_AUCTION_INFO_BY_AUCTION_ID, auction_id)
      GameDB.exec(DELETE_AUCTION_BID_INFO_BY_AUCTION_ID, auction_id)
      return
    end

    auction_bids = [] of ItemAuctionBid
    GameDB.each(SELECT_PLAYERS_ID_BY_AUCTION_ID, auction_id) do |rs|
      player_l2id = rs.get_i32(1)
      player_bid = rs.get_i64(2)
      bid = ItemAuctionBid.new(player_l2id, player_bid)
      auction_bids << bid
    end

    ItemAuction.new(auction_id, @instance_id, starting_time, ending_time, auction_item, auction_bids, auction_state)
  end
end
