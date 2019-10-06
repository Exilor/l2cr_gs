module ItemsAutoDestroy
  extend self
  extend Synchronizable

  private ITEMS = Concurrent::Map(Int32, L2ItemInstance).new

  def load
    ThreadPoolManager.schedule_general_at_fixed_rate(->remove_items, 5000, 5000)
  end

  def add_item(item : L2ItemInstance)
    sync do
      item.drop_time = Time.ms
      ITEMS[item.l2id] = item
    end
  end

  def remove_items
    sync do
      cur_time = Time.ms
      ITEMS.each_value do |item|
        if item.drop_time == 0 || !item.item_location.void?
          ITEMS.delete(item.l2id)
        else
          if item.template.auto_destroy_time > 0
            if cur_time - item.drop_time > item.template.auto_destroy_time
              L2World.remove_visible_object(item, item.world_region?)
              L2World.remove_object(item)
              ITEMS.delete(item.l2id)
              if Config.save_dropped_item
                ItemsOnGroundManager.remove_object(item)
              end
            end
          elsif item.template.has_ex_immediate_effect?
            if cur_time - item.drop_time > Config.herb_auto_destroy_time
              L2World.remove_visible_object(item, item.world_region?)
              L2World.remove_object(item)
              ITEMS.delete(item.l2id)
              if Config.save_dropped_item
                ItemsOnGroundManager.remove_object(item)
              end
            end
          else
            if Config.autodestroy_item_after == 0
              sleep_time = 3600000
            else
              sleep_time = Config.autodestroy_item_after * 1000
            end

            if cur_time - item.drop_time > sleep_time
              L2World.remove_visible_object(item, item.world_region?)
              L2World.remove_object(item)
              ITEMS.delete(item.l2id)
              if Config.save_dropped_item
                ItemsOnGroundManager.remove_object(item)
              end
            end
          end
        end
      end
    end
  end
end
