class TaskCleanUp < Task
  private NAME = "clean_up"

  def name : String
    NAME
  end

  def on_time_elapsed(task : ExecutedTask)
    timer = Timer.new
    GC.collect
    debug { "Garbage collected in #{timer} seconds." }
  end
end
