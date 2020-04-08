require "./task"
require "../enums/task_type"
require "./tasks/*"

module TaskManager
  extend self
  extend Loggable

  SQL_STATEMENTS = {
    "SELECT id,task,type,last_activation,param1,param2,param3 FROM global_tasks",
    "UPDATE global_tasks SET last_activation=? WHERE id=?",
    "SELECT id FROM global_tasks WHERE task=?",
    "INSERT INTO global_tasks (task,type,last_activation,param1,param2,param3) VALUES(?,?,?,?,?,?)"
  }

  private TASKS = Concurrent::Map(String, Task).new
  CURRENT_TASKS = Concurrent::Array(ExecutedTask).new

  def load
    timer = Timer.new

    init
    start_all_tasks

    info { "Loaded #{TASKS.size} tasks in #{timer} s." }
  end

  private def init
    register_task(TaskBirthday.new)
    register_task(TaskClanLeaderApply.new)
    register_task(TaskCleanUp.new)
    register_task(TaskDailySkillReuseClean.new)
    register_task(TaskGlobalVariablesSave.new)
    register_task(TaskOlympiadSave.new)
    register_task(TaskRaidPointsReset.new)
    register_task(TaskRecom.new)
    register_task(TaskRestart.new)
    register_task(TaskSevenSignsUpdate.new)
    register_task(TaskShutdown.new)
  end

  def register_task(task : Task)
    key = task.name
    unless TASKS.has_key?(key)
      task.init
      TASKS[key] = task
    end
  end

  private def start_all_tasks
    GameDB.each(SQL_STATEMENTS[0]) do |rs|
      key = rs.get_string("task").strip.downcase
      unless task = TASKS[key]?
        next
      end

      type = TaskType.parse(rs.get_string("type"))
      unless type.none?
        current = ExecutedTask.new(task, type, rs)
        if launch_task(current)
          CURRENT_TASKS << current
        end
      end
    end
  rescue e
    error "Error while loading Global task table."
    error e
  end

  private def launch_task(task : ExecutedTask) : Bool
    type = task.type
    delay = interval = 0i64

    case type
    when TaskType::STARTUP
      task.call
    when TaskType::SCHEDULED
      delay = task.params[0].to_i64
      task.scheduled = ThreadPoolManager.schedule_general(task, delay)
      return true
    when TaskType::FIXED_SCHEDULED
      delay = task.params[0].to_i64
      interval = task.params[1].to_i64
      task.scheduled = ThreadPoolManager.schedule_general_at_fixed_rate(task, delay, interval)
    when TaskType::TIME # L2J appears to have deprecated this
      # time stored as seconds as a string
      begin
        desired = task.params[0].to_i64
        desired = Time.from_ms(desired)
        diff = desired.ms - Time.ms
        if diff >= 0
          task.scheduled = ThreadPoolManager.schedule_general(task, diff)
          return true
        end
      rescue e
        error e
      end
    when TaskType::SPECIAL
      if result = task.task.launch_special(task)
        task.scheduled = result
        return true
      end
    when TaskType::GLOBAL_TASK
      interval = task.params[0].to_i64 * 86_400_000
      hour = task.params[1].split(':')
      if hour.size != 3
        warn { "Task #{task.id} has an incorrect hour format." }
        return false
      end
      check = Calendar.new
      check.ms = task.last_activation + interval
      min = Calendar.new
      begin
        min.hour = hour[0].to_i
        min.minute = hour[1].to_i
        min.second = hour[2].to_i
      rescue e
        error { "Task #{task.id} has an incorrect time format: #{hour}." }
        error e
        return false
      end
      delay = min.ms - Time.ms
      # check *after* min
      if check.after?(min) || delay < 0
        delay += interval
      end
      task.scheduled = ThreadPoolManager.schedule_general_at_fixed_rate(task, delay, interval)
      return true
    else
      # automatically added
    end


    false
  end

  def add_unique_task(task : String, type : TaskType, param1 : String, param2 : String, param3 : String, last_activation : Int64 = 0i64) : Bool
    none_found = true
    GameDB.each(SQL_STATEMENTS[2], task) do |rs|
      none_found = false
    end

    if none_found
      add_task(task, type, param1, param2, param3, last_activation)
    end

    true
  rescue e
    error e
    false
  end

  def add_task(task : String, type : TaskType, param1 : String, param2 : String, param3 : String, last_activation : Int64 = 0i64) : Bool
    GameDB.exec(
      SQL_STATEMENTS[3],
      task,
      type.to_s,
      last_activation,
      param1,
      param2,
      param3
    )
    true
  rescue e
    error e
    false
  end
end