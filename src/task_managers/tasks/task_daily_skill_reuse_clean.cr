class TaskDailySkillReuseClean < Task
  private NAME = "daily_skill_clean"
  private DAILY_SKILLS = {2510, 22180}

  def init
    super
    TaskManager.add_unique_task(NAME, TaskType::GLOBAL_TASK, "1", "06:30:00", "")
  end

  def name : String
    NAME
  end

  def on_time_elapsed(task : ExecutedTask)
    sql = "DELETE FROM character_skills_save WHERE skill_id=?;"
    DAILY_SKILLS.each do |skill_id|
      GameDB.exec(sql, skill_id)
    end
  rescue e
    error e
  else
    info "Daily skill reuse clean up completed."
  end
end
