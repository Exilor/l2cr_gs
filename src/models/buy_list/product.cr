class Product
  include Loggable

  @restock_task : TaskScheduler::DelayedTask?

  getter buy_list_id, item, restock_delay, max_count

  def initialize(@buy_list_id : Int32, @item : L2Item, @price : Int64, @restock_delay : Int64, @max_count : Int64)
    @restock_delay = restock_delay * 60_000
    @max_count = max_count

    if limited_stock?
      @count = Atomic(Int64).new(max_count)
    else
      @count = nil
    end
  end

  def item_id : Int32
    @item.id
  end

  def count : Int64
    temp = @count.try &.get
    temp && temp > 0 ? temp : 0i64
  end

  def count=(new_count : Int64)
    if count = @count
      count.set(new_count)
      @count = count
    else
      @count = Atomic(Int64).new(new_count)
    end
  end

  def price : Int64
    @price < 0 ? @item.reference_price.to_i64 : @price
  end

  def decrease_count(val : Int64) : Bool
    return false unless count = @count
    task = @restock_task
    if task.nil? || task.done?
      @restock_task = ThreadPoolManager.schedule_general(RestockTask.new(self), @restock_delay)
    end
    result = count.sub(val) - val >= 0
    @count = count
    save
    result
  end

  def limited_stock? : Bool
    @max_count > -1
  end

  def restart_restock_task(next_restock_time : Int64)
    remain_time = next_restock_time - Time.ms
    if remain_time > 0
      @restock_task = ThreadPoolManager.schedule_general(RestockTask.new(self), remain_time)
    else
      restock
    end
  end

  def restock
    debug "Restocking."
    self.count = max_count
    save
  end

  def save
    sql = "INSERT INTO `buylists`(`buylist_id`, `item_id`, `count`, `next_restock_time`) VALUES(?, ?, ?, ?) ON DUPLICATE KEY UPDATE `count` = ?, `next_restock_time` = ?"
    task = @restock_task

    if task && task.delay > 0
      next_restock_time = Time.ms + task.delay
      GameDB.exec(sql, buy_list_id, item_id, count, next_restock_time, count, next_restock_time)
    else
      GameDB.exec(sql, buy_list_id, item_id, count, 0, count, 0)
    end
  rescue e
    error e
  end

  private struct RestockTask
    initializer product : Product

    def call
      @product.restock
    end
  end
end
