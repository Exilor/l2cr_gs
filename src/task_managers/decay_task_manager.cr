module DecayTaskManager
  extend self

  private TASKS = Concurrent::Map(L2Character, TaskScheduler::DelayedTask).new
  private POOL = TaskScheduler.new(pool_size: 1)

  def add(char : L2Character)
    template = char.template.as?(L2NpcTemplate)
    delay = template ? template.corpse_time : Config.default_corpse_time

    if char.is_a?(L2Attackable) && (char.spoiled? || char.seeded?)
      delay += Config.spoiled_corpse_extend_time
    end

    add(char, delay)
  end

  def add(char : L2Character, delay)
    task = DecayTask.new(char)
    TASKS[char]?.try &.cancel
    TASKS[char] = POOL.schedule_delayed(task, delay.to_f64 * 1000)
  end

  def cancel(char : L2Character)
    if task = TASKS.delete(char)
      task.cancel
    end
  end

  def get_remaining_time(char : L2Character) : Int64
    (task = TASKS[char]?) ? task.delay : Int64::MAX
  end

  private struct DecayTask
    initializer char : L2Character

    def call
      TASKS.delete(@char)
      @char.on_decay
    end
  end
end
