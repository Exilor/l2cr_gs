module WarehouseCache
  extend self

  private CACHE = Hash(L2PcInstance, Int64).new
  @@CACHE_TIME = 0

  def load
    @@CACHE_TIME = Config.warehouse_cache_time * 60
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
      if Time.ms - time > @@CACHE_TIME
        pc.clear_warehouse
        CACHE.delete(pc)
      end
    end
  end
end
