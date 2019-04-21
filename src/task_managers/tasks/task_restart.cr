class TaskRestart < Task
  private NAME = "restart"

  def name : String
    NAME
  end

  def on_time_elapsed(task : ExecutedTask)
    time = task.params[2].to_i
    st = Shutdown.new(time, true)
    st.start
  end
end
