require "./abstract_zone_settings"

class TaskZoneSettings < AbstractZoneSettings
  property task : Concurrent::ScheduledTask?

  def clear
    if task = @task
      task.cancel
      @task = nil
    end
  end
end
