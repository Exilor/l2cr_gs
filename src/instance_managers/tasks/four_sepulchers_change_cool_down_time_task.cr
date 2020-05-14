struct FourSepulchersChangeCoolDownTimeTask
  def call
    manager = FourSepulchersManager
    manager.entry_time = false
    manager.warm_up_time = false
    manager.attack_time = false
    manager.cool_down_time = true

    manager.clean

    time = Calendar.new

    if !manager.first_time_run? && time.minute > manager.cycle_min
      time.hour &-= 1
    end

    time.minute = manager.cycle_min.to_i

    if manager.first_time_run?
      manager.first_time_run = false
    end

    interval = time.ms - Time.ms

    manager.change_entry_time_task =
    ThreadPoolManager.schedule_general(FourSepulchersChangeEntryTimeTask.new, interval)

    if task = manager.change_cool_down_time_task
      task.cancel
      manager.change_cool_down_time_task = nil
    end
  end
end
