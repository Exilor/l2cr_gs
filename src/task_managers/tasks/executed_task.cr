class ExecutedTask
  include Loggable

  getter task, type
  getter id : Int32
  getter params : {String, String, String}
  getter last_activation : Int64
  property scheduled : TaskExecutor::Scheduler::Task?

  def_equals_and_hash @id

  def initialize(@task : Task, @type : TaskType, rs : ResultSetReader)
    @id = rs.get_i32(:"id")
    @last_activation = rs.get_i64(:"last_activation")
    @params = {
      rs.get_string(:"param1"),
      rs.get_string(:"param2"),
      rs.get_string(:"param3")
    }
  end

  def call
    task.on_time_elapsed(self)
    @last_activation = Time.ms

    begin
      GameDB.exec(TaskManager::SQL_STATEMENTS[1], @last_activation, @id)
    rescue e
      error e
    end

    if @type.scheduled? || @type.time?
      stop_task
    end
  end

  def stop_task
    task.on_destroy
    @scheduled.try &.cancel
    TaskManager::CURRENT_TASKS.delete_first(self)
  end
end
