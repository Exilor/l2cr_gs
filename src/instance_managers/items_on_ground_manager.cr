module ItemsOnGroundManager
  extend self
  extend Synchronizable
  extend Loggable

  private ITEMS = Concurrent::Array(L2ItemInstance).new

  def load
    time = Config.save_dropped_item_interval
    if time > 0
      ThreadPoolManager.schedule_general_at_fixed_rate(self, time, time)
    end
    load_from_db
  end

  private def load_from_db
    if !Config.save_dropped_item && Config.clear_dropped_item_table
      empty_table
    end

    unless Config.save_dropped_item
      return
    end

    total = 0
    timer = Timer.new

    if Config.destroy_dropped_player_item
      if !Config.destroy_equipable_player_item
        sql = "UPDATE itemsonground SET drop_time = ? WHERE drop_time = -1 AND equipable = 0"
      elsif Config.destroy_equipable_player_item
        sql = "UPDATE itemsonground SET drop_time = ? WHERE drop_time = -1"
      end

      if sql
        begin
          GameDB.exec(sql, Time.ms)
        rescue e
          error e
        end
      end
    end

    sql = "SELECT object_id,item_id,count,enchant_level,x,y,z,drop_time,equipable FROM itemsonground"
    GameDB.query_each(sql) do |rs|
      l2id = rs.read(Int32)
      item_id = rs.read(Int32)
      count = rs.read(Int64)
      enchant_lvl = rs.read(Int32)
      x, y, z = rs.read(Int32, Int32, Int32)
      drop_time = rs.read(Int64)

      item = L2ItemInstance.new(l2id, item_id)
      L2World.store_object(item)

      if item.stackable? && count > 1
        item.count = count
      end

      if enchant_lvl > 0
        item.enchant_level = enchant_lvl
      end

      item.set_xyz(x, y, z)
      item.world_region = L2World.get_region(item)
      item.world_region.not_nil!.add_visible_object(item)
      item.drop_time = drop_time
      item.protected = drop_time == -1
      item.visible = true
      L2World.add_visible_object(item, item.world_region.not_nil!)
      ITEMS << item
      total &+= 1
      unless Config.list_protected_items.includes?(item.id)
        if drop_time > -1
          if Config.autodestroy_item_after > 0 && !item.template.has_ex_immediate_effect?
            ItemsAutoDestroy.add_item(item)
          elsif Config.herb_auto_destroy_time > 0 && item.template.has_ex_immediate_effect?
            ItemsAutoDestroy.add_item(item)
          end
        end
      end
    end

    info { "Loaded #{total} dropped items in #{timer} s." }

    if Config.empty_dropped_item_table_after_load
      empty_table
    end
  end

  def empty_table
    GameDB.exec("DELETE FROM itemsonground")
  rescue e
    error e
  end

  def remove_object(item : L2ItemInstance)
    if Config.save_dropped_item
      ITEMS.delete_first(item)
    end
  end

  def save(item : L2ItemInstance)
    if Config.save_dropped_item
      ITEMS << item
    end
  end

  def call
    sync do
      unless Config.save_dropped_item
        return
      end

      empty_table

      if ITEMS.empty?
        debug "No dropped items to save."
        return
      end

      timer = Timer.new
      debug "Saving..."

      sql = "INSERT INTO itemsonground(object_id,item_id,count,enchant_level,x,y,z,drop_time,equipable) VALUES(?,?,?,?,?,?,?,?,?)"
      begin
        GameDB.transaction do |tr|
          ITEMS.each do |item|
            if CursedWeaponsManager.cursed?(item.id)
              next
            end

            tr.exec(
              sql,
              item.l2id,
              item.id,
              item.count,
              item.enchant_level,
              *item.xyz,
              item.protected? ? -1 : item.drop_time,
              item.equippable? ? 1 : 0
            )
          end
        end
      rescue e
        error e
      end

      debug { "Saved #{ITEMS.size} items in #{timer} s." }
    end
  end

  def save_in_db
    call
  end

  def clean_up
    ITEMS.clear
  end
end
