require "./abstract_zone_settings"

class TaskZoneSettings < AbstractZoneSettings
  property task : TaskScheduler::Task?

  def clear
    if task = @task
      task.cancel
      @task = nil
    end
  end
end
