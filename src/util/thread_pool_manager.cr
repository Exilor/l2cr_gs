module ThreadPoolManager
  extend self

  def schedule_effect(task, delay) : Runnable::DelayedTask
    schedule_delayed(task, delay)
  end

  def schedule_effect_at_fixed_rate(task, delay, interval) : Runnable::PeriodicTask
    schedule_periodic(task, delay, interval)
  end

  def schedule_general(task, delay) : Runnable::DelayedTask
    schedule_delayed(task, delay)
  end

  def schedule_general_at_fixed_rate(task, delay, interval) : Runnable::PeriodicTask
    schedule_periodic(task, delay, interval)
  end

  def schedule_event(task, delay) : Runnable::DelayedTask
    schedule_delayed(task, delay)
  end

  def schedule_event_at_fixed_rate(task, delay, interval) : Runnable::PeriodicTask
    schedule_periodic(task, delay, interval)
  end

  def schedule_ai(task, delay) : Runnable::DelayedTask
    schedule_delayed(task, delay)
  end

  def schedule_ai_at_fixed_rate(task, delay, interval) : Runnable::PeriodicTask
    schedule_periodic(task, delay, interval)
  end

  def execute_packet(task)
    schedule(task)
  end

  def execute_io_packet(task)
    schedule(task)
  end

  def execute_general(task)
    schedule(task)
  end

  def execute_ai(task)
    schedule(task)
  end

  def execute_event(task)
    schedule(task)
  end

  private POOL = RunnableExecutor.new

  private def schedule(task)
    POOL.schedule(task)
  end

  private def schedule_delayed(task, delay)
    POOL.schedule_delayed(task, delay)
  end

  private def schedule_periodic(task, delay, interval)
    POOL.schedule_periodic(task, delay, interval)
  end
end
