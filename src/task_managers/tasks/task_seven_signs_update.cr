class TaskSevenSignsUpdate < Task
  private NAME = "seven_signs_update"

  def init
    super
    TaskManager.add_unique_task(NAME, TaskType::FIXED_SCHEDULED, "1800000", "1800000", "")
  end

  def name : String
    NAME
  end

  def on_time_elapsed(task : ExecutedTask)
    SevenSigns.instance.save_seven_signs_status
    unless SevenSigns.instance.seal_validation_period?
      SevenSignsFestival.instance.save_festival_data(false)
    end

    info "Saved SevenSigns data."
  rescue e
    error e
  end
end
