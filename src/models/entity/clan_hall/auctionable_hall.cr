require "../clan_hall"

class AuctionableHall < ClanHall
  @ch_rate = 604800000

  getter lease : Int32
  getter paid_until : Int64
  getter grade : Int32
  getter? paid : Bool

  def initialize(set : StatsSet)
    super

    @paid_until = set.get_i64("paidUntil")
    @grade = set.get_i32("grade")
    @paid = set.get_bool("paid")
    @lease = set.get_i32("lease")

    if owner_id != 0
      @free = false
      initialize_task(false)
      load_functions
    end
  end

  def free
    super

    @paid_until = 0i64
    @paid = false
  end

  def owner=(clan : L2Clan?)
    super

    @paid_until = Time.ms
    initialize_task(true)
  end

  private def initialize_task(forced : Bool)
    time = Time.ms

    if @paid_until > time
      ThreadPoolManager.schedule_general(->fee_task, @paid_until - time)
    elsif !@paid && !forced
      if time + (3_600_000 * 24) <= @paid_until + @ch_rate
        ThreadPoolManager.schedule_general(->fee_task, time + (3_600_000 * 24))
      else
        ThreadPoolManager.schedule_general(->fee_task, (@paid_until + @ch_rate) - time)
      end
    else
      ThreadPoolManager.schedule_general(->fee_task, 0)
    end
  end

  private def fee_task
    return if free?

    time = Time.ms

    if @paid_until > time
      ThreadPoolManager.schedule_general(->fee_task, @paid_until - time)
      return
    end

    clan = ClanTable.get_clan(owner_id).not_nil!
    wh = clan.warehouse

    if wh.adena >= lease
      if @paid_until != 0
        while @paid_until <= time
          @paid_until += @ch_rate
        end
      else
        @paid_until = time + @ch_rate
      end

      wh.destroy_item_by_item_id("CH_rental_fee", Inventory::ADENA_ID, lease.to_i64, nil, nil)
      ThreadPoolManager.schedule_general(->fee_task, @paid_until - time)
      @paid = true
      update_db
    else
      @paid = false

      if time > @paid_until + @ch_rate
        if ClanHallManager.loaded?
          AuctionManager.init_npc(id)
          ClanHallManager.set_free(id)
          clan.broadcast_to_online_members(SystemMessage.the_clan_hall_fee_is_one_week_overdue_therefore_the_clan_hall_ownership_has_been_revoked)
        else
          ThreadPoolManager.schedule_general(->fee_task, 3000)
        end
      else
        update_db
        sm = SystemMessage.payment_for_your_clan_hall_has_not_been_made_please_make_payment_to_your_clan_warehouse_by_s1_tomorrow
        sm.add_int(lease)
        clan.broadcast_to_online_members(sm)

        if time + (3_600_000 * 24) <= @paid_until + @ch_rate
          ThreadPoolManager.schedule_general(->fee_task, time + (3_600_000 * 24))
        else
          ThreadPoolManager.schedule_general(->fee_task, (@paid_until + @ch_rate) - time)
        end
      end
    end
  rescue e
    error e
  end

  def update_db
    sql = "UPDATE clanhall SET ownerId=?, paidUntil=?, paid=? WHERE id=?"
    GameDB.exec(sql, owner_id, paid_until, paid? ? 1 : 0, id)
  rescue e
    error e
  end
end
