struct FourSepulchersChangeWarmUpTimeTask
  def call
    manager = FourSepulchersManager
    manager.entry_time = true
    manager.warm_up_time = false
    manager.attack_time = false
    manager.cool_down_time = false

    if manager.first_time_run?
      interval = manager.warm_up_time_end - Time.ms
    else
      interval = Config.fs_time_warmup.to_i64 * 60000
    end

    manager.change_attack_time_task =
    ThreadPoolManager.schedule_general(FourSepulchersChangeAttackTimeTask.new, interval)
    if task = manager.change_warm_up_time_task
      task.cancel
      manager.change_warm_up_time_task = nil
    end
  end
end
