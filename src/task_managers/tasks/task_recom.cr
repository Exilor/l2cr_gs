class TaskRecom < Task
  private NAME = "recommendations"

  def init
    super
    TaskManager.add_unique_task(NAME, TaskType::GLOBAL_TASK, "1", "06:30:00", "")
  end

  def name : String
    NAME
  end

  def on_time_elapsed(task : ExecutedTask)
    sql = "UPDATE character_reco_bonus SET rec_left=?, time_left=?, rec_have=0 WHERE rec_have <=  20"
    GameDB.exec(sql, 0, 3_600_000)
    sql = "UPDATE character_reco_bonus SET rec_left=?, time_left=?, rec_have=GREATEST(rec_have-20,0) WHERE rec_have > 20"
    GameDB.exec(sql, 0, 3_600_000)
  rescue e
    error e
  else
    info "Recommendations resetted."
  end
end
