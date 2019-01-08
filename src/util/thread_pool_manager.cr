module ThreadPoolManager
  extend self
  extend Loggable

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
    execute_task(task)
  end

  def execute_io_packet(task)
    execute_task(task)
  end

  def execute_general(task)
    execute_task(task)
  end

  def execute_ai(task)
    execute_task(task)
  end

  def execute_event(task)
    execute_task(task)
  end

  #

  # private def execute_task(task : Proc)
  #   execute_task(Runnable::RunnableProc.new(&task))
  # end

  # private def execute_task(task : Runnable)
  #   task.start
  # end

  # private def schedule_delayed(task : Proc, delay)
  #   schedule_delayed(Runnable::RunnableProc.new(&task), delay)
  # end

  # private def schedule_delayed(task : Runnable, delay)
  #   task.mstart(delay)
  # end

  # private def schedule_periodic(task : Proc, delay, interval)
  #   schedule_periodic(Runnable::RunnableProc.new(&task), delay, interval)
  # end

  # private def schedule_periodic(task : Runnable, delay, interval)
  #   task.mstart(delay, interval)
  # end

  POOL = RunnableExecutor.new

  private def execute_task(task)
    POOL.schedule(task)
  end

  private def schedule_delayed(task, delay)
    POOL.schedule_delayed(task, delay)
  end

  private def schedule_periodic(task, delay, interval)
    POOL.schedule_periodic(task, delay, interval)
  end
end
