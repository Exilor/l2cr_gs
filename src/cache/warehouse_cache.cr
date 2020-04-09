module WarehouseCache
  extend self

  private CACHE = Concurrent::Map(L2PcInstance, Int64).new

  @@cache_time = 0i64

  def load
    @@cache_time = Config.warehouse_cache_time.to_i64 * 60_000
    ThreadPoolManager.schedule_ai_at_fixed_rate(self, 120_000, 60_000)
  end

  def add_cache_task(pc : L2PcInstance)
    CACHE[pc] = Time.ms
  end

  def delete(pc : L2PcInstance)
    CACHE.delete(pc)
  end

  def call
    CACHE.each do |pc, time|
      if Time.ms - time > @@cache_time
        pc.clear_warehouse
        CACHE.delete(pc)
      end
    end
  end
end
