class TaskShutdown < Task
  private NAME = "shutdown"

  def name : String
    NAME
  end

  def on_time_elapsed(task : ExecutedTask)
    time = task.params[2].to_i
    st = Shutdown.new(time, false)
    st.start
  end
end
