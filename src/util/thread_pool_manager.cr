module ThreadPoolManager
  extend self

  def schedule_effect(task, delay) : Concurrent::DelayedTask
    Concurrent.schedule_delayed(task, delay)
  end

  def schedule_effect_at_fixed_rate(task, delay, interval) : Concurrent::PeriodicTask
    Concurrent.schedule_periodic(task, delay, interval)
  end

  def schedule_general(task, delay) : Concurrent::DelayedTask
    Concurrent.schedule_delayed(task, delay)
  end

  def schedule_general_at_fixed_rate(task, delay, interval) : Concurrent::PeriodicTask
    Concurrent.schedule_periodic(task, delay, interval)
  end

  def schedule_event(task, delay) : Concurrent::DelayedTask
    Concurrent.schedule_delayed(task, delay)
  end

  def schedule_event_at_fixed_rate(task, delay, interval) : Concurrent::PeriodicTask
    Concurrent.schedule_periodic(task, delay, interval)
  end

  def schedule_ai(task, delay) : Concurrent::DelayedTask
    Concurrent.schedule_delayed(task, delay)
  end

  def schedule_ai_at_fixed_rate(task, delay, interval) : Concurrent::PeriodicTask
    Concurrent.schedule_periodic(task, delay, interval)
  end

  def execute_packet(task)
    Concurrent.schedule(task)
  end

  def execute_io_packet(task)
    Concurrent.schedule(task)
  end

  def execute_general(task)
    Concurrent.schedule(task)
  end

  def execute_ai(task)
    Concurrent.schedule(task)
  end

  def execute_event(task)
    Concurrent.schedule(task)
  end
end
