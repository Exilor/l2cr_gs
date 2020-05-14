require "../models/date_range"

module EventDroplist
  extend self

  private DROPS = [] of DateDrop

  record DateDrop, date_range : DateRange, event_drop : EventDrop

  def add_global_drop(item_id_list : Slice(Int32), count : Slice(Int32), chance : Int32, date_range : DateRange)
    drop = EventDrop.new(item_id_list, count[0], count[1], chance)
    DROPS << DateDrop.new(date_range, drop)
  end

  def add_global_drop(item_id : Int32, min : Int64, max : Int64, chance : Int32, date_range : DateRange)
    drop = EventDrop.new(item_id, min, max, chance)
    DROPS << DateDrop.new(date_range, drop)
  end

  def add_global_drop(date_range : DateRange, event_drop : EventDrop)
    DROPS << DateDrop.new(date_range, event_drop)
  end

  def all_drops : Array(DateDrop)
    time = Time.now
    DROPS.select &.includes?(time)
  end

  private struct EventDrop
    getter_initializer item_id_list : Slice(Int32), min_count : Int64,
      max_count : Int64, drop_chance : Int32

    def initialize(item_id : Int32, min : Int64, max : Int64, drop_chance : Int32)
      @item_id_list = Slice.new(1, item_id)
      @min_count = min
      @max_count = max
      @drop_chance = drop_chance
    end
  end
end
