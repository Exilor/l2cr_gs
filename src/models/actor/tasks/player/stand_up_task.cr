struct StandUpTask
  initializer pc : L2PcInstance

  def call
    @pc.sitting = false
    @pc.intention = AI::IDLE
  end
end
