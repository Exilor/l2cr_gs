struct TrapUnsummonTask
  include Runnable

  initializer trap: L2TrapInstance

  def run
    @trap.unsummon
  end
end
