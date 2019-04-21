class TaskOlympiadSave < Task
  private NAME = "olympiad_save"

  def init
    super
    TaskManager.add_unique_task(NAME, TaskType::FIXED_SCHEDULED, "900000", "1800000", "")
  end

  def name : String
    NAME
  end

  def on_time_elapsed(task : ExecutedTask)
    if Olympiad.instance.in_comp_period?
      Olympiad.instance.save_olympiad_status
      info "Olympiad data saved"
    end
  end
end
