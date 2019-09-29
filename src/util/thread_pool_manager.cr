module ThreadPoolManager
  extend self

  def schedule_effect(task, delay) : Scheduler::DelayedTask
    Scheduler.schedule_delayed(task, delay)
  end

  def schedule_effect_at_fixed_rate(task, delay, interval) : Scheduler::PeriodicTask
    Scheduler.schedule_periodic(task, delay, interval)
  end

  def schedule_general(task, delay) : Scheduler::DelayedTask
    Scheduler.schedule_delayed(task, delay)
  end

  def schedule_general_at_fixed_rate(task, delay, interval) : Scheduler::PeriodicTask
    Scheduler.schedule_periodic(task, delay, interval)
  end

  def schedule_event(task, delay) : Scheduler::DelayedTask
    Scheduler.schedule_delayed(task, delay)
  end

  def schedule_event_at_fixed_rate(task, delay, interval) : Scheduler::PeriodicTask
    Scheduler.schedule_periodic(task, delay, interval)
  end

  def schedule_ai(task, delay) : Scheduler::DelayedTask
    Scheduler.schedule_delayed(task, delay)
  end

  def schedule_ai_at_fixed_rate(task, delay, interval) : Scheduler::PeriodicTask
    Scheduler.schedule_periodic(task, delay, interval)
  end

  def execute_packet(task)
    Scheduler.schedule(task)
  end

  def execute_io_packet(task)
    Scheduler.schedule(task)
  end

  def execute_general(task)
    Scheduler.schedule(task)
  end

  def execute_ai(task)
    Scheduler.schedule(task)
  end

  def execute_event(task)
    Scheduler.schedule(task)
  end

  def stats : String
    "This implementation of ThreadPoolManager doesn't have stats to report"
  end
end
