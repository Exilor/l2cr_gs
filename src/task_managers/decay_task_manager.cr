module DecayTaskManager
  extend self
  extend Loggable

  private POOL = RunnableExecutor.new

  private TASKS = Hash(L2Character, Runnable::DelayedTask).new

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
    runnable = POOL.schedule_delayed(task, delay * 1000)
    TASKS[char]?.try &.cancel
    TASKS[char] = runnable
  end

  def cancel(char : L2Character)
    TASKS.delete(char).try &.cancel
  end

  def get_remaining_time(char : L2Character) : Int64
    TASKS[char]?.try &.delay.to_i64 || Int64::MAX
  end

  private struct DecayTask
    include Runnable

    initializer char: L2Character

    def run
      TASKS.delete(@char)
      @char.on_decay
    end
  end
end
