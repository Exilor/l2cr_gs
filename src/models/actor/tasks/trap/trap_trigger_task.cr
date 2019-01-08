struct TrapTriggerTask
  include Runnable
  include Loggable

  initializer trap: L2TrapInstance

  def run
    @trap.do_cast(@trap.skill)
    task = TrapUnsummonTask.new(@trap)
    ThreadPoolManager.schedule_general(task, @trap.skill.hit_time + 300)
  rescue e
    error e
    @trap.unsummon
  end
end
