module DecayTaskManager
  extend self

  private TASKS = Concurrent::Map(L2Character, Scheduler::DelayedTask).new

  def add(char : L2Character)
    if template = char.template.as?(L2NpcTemplate)
      delay = template.corpse_time
    else
      delay = Config.default_corpse_time
    end

    if char.is_a?(L2Attackable) && (char.spoiled? || char.seeded?)
      delay += Config.spoiled_corpse_extend_time
    end

    add(char, delay)
  end

  def add(char : L2Character, delay)
    task = DecayTask.new(char)
    scheduled = Scheduler.schedule_delayed(task, delay.to_f64 * 1000)
    TASKS[char]?.try &.cancel
    TASKS[char] = scheduled
  end

  def cancel(char : L2Character)
    TASKS.delete(char).try &.cancel
  end

  def get_remaining_time(char : L2Character) : Int64
    TASKS.fetch(char) { return Int64::MAX }.delay
  end

  private struct DecayTask
    initializer char : L2Character

    def call
      TASKS.delete(@char)
      @char.on_decay
    end
  end
end
