class TaskGlobalVariablesSave < Task
  private NAME = "global_varibales_save"

  def init
    super
    TaskManager.add_unique_task(NAME, TaskType::FIXED_SCHEDULED, "500000", "1800000", "")
  end

  def name : String
    NAME
  end

  def on_time_elapsed(task : ExecutedTask)
    GlobalVariablesManager.store_me
  end
end
