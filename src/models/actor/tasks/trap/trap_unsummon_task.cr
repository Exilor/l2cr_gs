struct TrapUnsummonTask
  initializer trap : L2TrapInstance

  def call
    @trap.unsummon
  end
end
