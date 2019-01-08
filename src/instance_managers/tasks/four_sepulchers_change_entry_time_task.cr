struct FourSepulchersChangeEntryTimeTask
  include Runnable

  def run
    manager = FourSepulchersManager
    manager.entry_time = true
    manager.warm_up_time = false
    manager.attack_time = false
    manager.cool_down_time = false

    if manager.first_time_run?
      interval = manager.entry_time_end - Time.ms
    else
      interval = Config.fs_time_entry.to_i64 * 60000
    end

    ThreadPoolManager.schedule_general(FourSepulchersManagerSayTask.new, 0)
    manager.change_warm_up_time_task =
    ThreadPoolManager.schedule_effect(FourSepulchersChangeWarmUpTimeTask.new, interval)
    if task = manager.change_entry_time_task
      task.cancel
      manager.change_entry_time_task = nil
    end
  end
end
