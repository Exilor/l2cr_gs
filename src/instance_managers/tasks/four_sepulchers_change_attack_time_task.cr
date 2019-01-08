require "./four_sepulchers_manager_say_task"

struct FourSepulchersChangeAttackTimeTask
  include Runnable

  def run
    manager = FourSepulchersManager
    manager.entry_time = false
    manager.warm_up_time = false
    manager.attack_time = true
    manager.cool_down_time = false

    manager.location_shadow_spawns

    31921.upto(31924) { |n| manager.spawn_mysterious_box(n) }

    unless manager.first_time_run?
      manager.warm_up_time_end = Time.ms
    end

    interval = 0i64

    if manager.first_time_run?
      min = Calendar.new.minute.to_f
      while min < manager.cycle_min
        if min % 5 == 0
          inter = Calendar.new
          inter.minute = min.to_i
          ThreadPoolManager.schedule_general(FourSepulchersManagerSayTask.new, inter.ms - Time.ms)
          break
        end

        min += 1
      end
    else
      ThreadPoolManager.schedule_general(FourSepulchersManagerSayTask.new, 5 * 60400)
    end

    if manager.first_time_run?
      interval = manager.attack_time_end - Time.ms
    else
      interval = Config.fs_time_attack.to_i64 * 60000
    end

    manager.change_cool_down_time_task =
    ThreadPoolManager.schedule_general(FourSepulchersChangeCoolDownTimeTask.new, interval)

    if task = manager.change_attack_time_task
      task.cancel
      manager.change_attack_time_task = nil
    end
  end
end
