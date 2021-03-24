struct FourSepulchersManagerSayTask
  def call
    if FourSepulchersManager.attack_time?
      tmp = Calendar.new
      tmp.ms &-= FourSepulchersManager.warm_up_time_end
      if tmp.minute &+ 5 < Config.fs_time_attack
        FourSepulchersManager.manager_say(tmp.minute.to_i8)
        ThreadPoolManager.schedule_general(FourSepulchersManagerSayTask.new, 5 * 60_000)
      elsif tmp.minute &+ 5 >= Config.fs_time_attack
        FourSepulchersManager.manager_say(90)
      end
    elsif FourSepulchersManager.entry_time?
      FourSepulchersManager.manager_say(0)
    end
  end
end
