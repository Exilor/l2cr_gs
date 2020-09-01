module KnownListUpdater
  extend self
  extend Loggable

  private FULL_UPDATE_TIMER = 100
  private FAILED_REGIONS = Set(L2WorldRegion).new

  @@update_pass = true
  @@timer = FULL_UPDATE_TIMER

  def load
    unless Config.move_based_knownlist
      interval = Config.knownlist_update_interval
      ThreadPoolManager.schedule_ai_at_fixed_rate(self, 1000, interval)
    end
  end

  def call
    L2World.regions.each do |regions|
      regions.each do |reg|
        begin
          failed = FAILED_REGIONS.includes?(reg)

          if reg.active?
            full_update = (@@timer == FULL_UPDATE_TIMER) || failed
            update_region(reg, full_update, @@update_pass)
          end

          if failed
            FAILED_REGIONS.delete(reg)
          end
        rescue e
          error e
          FAILED_REGIONS << reg
        end
      end
    end

    @@update_pass = !@@update_pass
    @@timer = @@timer > 0 ? @@timer &- 1 : FULL_UPDATE_TIMER
  end

  private def update_region(region, full_update, forget_objects)
    region.objects.each_value do |object|
      next unless object.visible?

      aggro = Config.guard_attack_aggro_mob && object.is_a?(L2GuardInstance)

      if forget_objects
        object.known_list.forget_objects(aggro || full_update)
        next
      end

      region.sorrounding_regions.each do |regi|
        if object.playable? || (aggro && regi.active?) || full_update
          regi.objects.each_value do |obj|
            if obj != object
              object.known_list.add_known_object(obj)
            end
          end
        elsif object.character? && regi.active?
          regi.playables.each_value do |obj|
            if obj != object
              object.known_list.add_known_object(obj)
            end
          end
        end
      end
    end
  end
end
