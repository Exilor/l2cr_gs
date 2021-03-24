module ThreadPoolManager
  extend self
  include Loggable

  private class_getter(effects_scheduled_thread_pool) { TaskScheduler.new(pool_size: Config.thread_p_effects, error_handler: ->Logs.error(Exception)) }
  private class_getter(general_scheduled_thread_pool) { TaskScheduler.new(pool_size: Config.thread_p_general, error_handler: ->Logs.error(Exception)) }
  private class_getter(event_scheduled_thread_pool)   { TaskScheduler.new(pool_size: Config.thread_e_events, error_handler: ->Logs.error(Exception)) }
  private class_getter(io_packets_thread_pool)        { TaskExecutor.new(pool_size: Config.io_packet_thread_core_size, error_handler: ->Logs.error(Exception)) }
  private class_getter(general_packets_thread_pool)   { TaskExecutor.new(pool_size: Config.general_packet_thread_core_size + 2, error_handler: ->Logs.error(Exception)) }
  private class_getter(general_thread_pool)           { TaskExecutor.new(pool_size: Config.general_thread_core_size, error_handler: ->Logs.error(Exception)) }
  private class_getter(ai_scheduled_thread_pool)      { TaskScheduler.new(pool_size: Config.ai_max_thread, error_handler: ->Logs.error(Exception)) }
  private class_getter(event_thread_pool)             { TaskExecutor.new(pool_size: Config.event_max_thread + 2, error_handler: ->Logs.error(Exception)) }

  def schedule_effect(task, delay) : TaskScheduler::DelayedTask
    schedule_delayed(task, delay, effects_scheduled_thread_pool)
  end

  def schedule_effect_at_fixed_rate(task, delay, interval) : TaskScheduler::PeriodicTask
    schedule_periodic(task, delay, interval, effects_scheduled_thread_pool)
  end

  def schedule_general(task, delay) : TaskScheduler::DelayedTask
    schedule_delayed(task, delay, general_scheduled_thread_pool)
  end

  def schedule_general_at_fixed_rate(task, delay, interval) : TaskScheduler::PeriodicTask
    schedule_periodic(task, delay, interval, general_scheduled_thread_pool)
  end

  def schedule_event(task, delay) : TaskScheduler::DelayedTask
    schedule_delayed(task, delay, event_scheduled_thread_pool)
  end

  def schedule_event_at_fixed_rate(task, delay, interval) : TaskScheduler::PeriodicTask
    schedule_periodic(task, delay, interval, event_scheduled_thread_pool)
  end

  def schedule_ai(task, delay) : TaskScheduler::DelayedTask
    schedule_delayed(task, delay, ai_scheduled_thread_pool)
  end

  def schedule_ai_at_fixed_rate(task, delay, interval) : TaskScheduler::PeriodicTask
    schedule_periodic(task, delay, interval, ai_scheduled_thread_pool)
  end

  def execute_packet(task)
    execute_task(task, general_packets_thread_pool)
  end

  def execute_io_packet(task)
    execute_task(task, io_packets_thread_pool)
  end

  def execute_general(task)
    execute_task(task, general_thread_pool)
  end

  def execute_ai(task)
    execute_task(task, ai_scheduled_thread_pool)
  end

  def execute_event(task)
    execute_task(task, event_thread_pool)
  end

  private def execute_task(task, pool)
    pool.execute(task)
  end

  private def schedule_delayed(task, delay, pool)
    pool.schedule_delayed(task, delay)
  end

  private def schedule_periodic(task, delay, interval, pool)
    pool.schedule_periodic(task, delay, interval)
  end

  def shutdown
    timer = Timer.new

    debug "Shutting down effects_scheduled_thread_pool."
    @@effects_scheduled_thread_pool.try &.shutdown

    debug "Shutting down general_scheduled_thread_pool."
    @@general_scheduled_thread_pool.try &.shutdown

    debug "Shutting down event_scheduled_thread_pool."
    @@event_scheduled_thread_pool.try &.shutdown

    debug "Shutting down io_packets_thread_pool."
    @@io_packets_thread_pool.try &.shutdown

    debug "Shutting down general_packets_thread_pool."
    @@general_packets_thread_pool.try &.shutdown

    debug "Shutting down general_thread_pool."
    @@general_thread_pool.try &.shutdown

    debug "Shutting down ai_scheduled_thread_pool."
    @@ai_scheduled_thread_pool.try &.shutdown

    debug "Shutting down event_thread_pool."
    @@event_thread_pool.try &.shutdown

    info { "Thread pools terminated in #{timer} s." }
  end
end
