module DecayTaskManager
  extend self
  extend Loggable

  private TASKS = Hash(L2Character, Concurrent::DelayedTask).new

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
    scheduled = Concurrent.schedule_delayed(task, delay * 1000)
    TASKS[char]?.try &.cancel
    TASKS[char] = scheduled
  end

  def cancel(char : L2Character)
    TASKS.delete(char).try &.cancel
  end

  def get_remaining_time(char : L2Character) : Int64
    TASKS[char]?.try &.delay.to_i64 || Int64::MAX
  end

  private struct DecayTask
    initializer char: L2Character

    def call
      TASKS.delete(@char)
      @char.on_decay
    end
  end
end
