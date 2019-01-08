require "./abstract_zone_settings"

class TaskZoneSettings < AbstractZoneSettings
  property task : Runnable::RunnableTask?

  def clear
    if task = @task
      task.cancel
      @task = nil
    end
  end
end
